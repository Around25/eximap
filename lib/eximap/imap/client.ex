defmodule Eximap.Imap.Client do
  use GenServer
  alias Eximap.Imap.Request
  alias Eximap.Imap.Response
  alias Eximap.Socket

  @moduledoc """
  Imap Client GenServer
  """

  @initial_state %{socket: nil, tag_number: 1}

  def start_link do
    GenServer.start_link(__MODULE__, @initial_state)
  end

  def init(state) do
    opts = [:binary, active: false]
    host = Application.get_env(:eximap, :incoming_mail_server) |> to_charlist
    port = Application.get_env(:eximap, :incoming_port)
    account = Application.get_env(:eximap, :account)
    pass = Application.get_env(:eximap, :password)

    # todo: Hardcoded SSL connection until I implement the Authentication algorithms to allow login over :gen_tcp
    {:ok, socket} = Socket.connect(true, host, port, opts)
    state = %{state | socket: socket}

    # todo: parse the server attributes and store them in the state
    imap_receive_raw(socket)

    # login using the account name and password
    req = Request.login(account, pass) |> Request.add_tag("EX_LGN")
    imap_send(socket, req)
    {:ok, %{state | socket: socket}}
  end

  def execute(pid, req) do
    GenServer.call(pid, {:command, req})
  end

  def handle_call({:command, %Request{} = req}, _from, %{socket: socket, tag_number: tag_number} = state) do
    resp = imap_send(socket, %Request{req | tag: "EX#{tag_number}"})
    {:reply, resp, %{state | tag_number: tag_number + 1}}
  end

  def handle_info(resp, state) do
    IO.inspect resp
    {:noreply, state}
  end

  #
  # Private methods
  #

  defp imap_send(socket, req) do
    message = Request.raw(req)
    imap_send_raw(socket, message)
    imap_receive(socket, req)
  end

  defp imap_send_raw(socket, msg) do
#    IO.inspect "C: #{msg}"
    Socket.send(socket, msg)
  end

  defp imap_receive(socket, req) do
    {:ok, msg} = Socket.recv(socket, 0)

    %Response{request: req} |> parse_message(msg)
  end

  defp parse_message(resp, ""), do: resp
  defp parse_message(resp, message) do
    [head | [tail]] = String.split(message, "\r\n", parts: 2)
    {:ok, resp, tail} = Response.parse(resp, head, tail)
    if (resp.partial) do
      parse_message(resp, tail)
    else
      resp
    end
  end

  defp imap_receive_raw(socket) do
    {:ok, msg} = Socket.recv(socket, 0)
    msgs = String.split(msg, "\r\n", parts: 2)
    msgs = Enum.drop msgs, -1
#    Enum.map(msgs, &(IO.inspect "S: #{&1}"))
    msgs
  end

end