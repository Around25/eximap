defmodule Eximap.Imap.Client do
  use GenServer
  alias Eximap.Imap.Request
  alias Eximap.Imap.Response

  @moduledoc """
  Imap Client GenServer

  TODOs:
  - Generate unique tag for each request: "A000001 COMMAND BODY \r\n"

  iex> {:ok, pid} = Eximap.Imap.Client.start_link()
  iex> req = Eximap.Imap.Request.noop()
  iex> Eximap.Imap.Client.execute(pid, req)
  "EX2 OK NOOP completed.\\r\\n"

  #  iex> Eximap.Imap.Client.command(pid, "A0001 LOGIN cosmin@localhost.dev secret")

  """

  @initial_state %{socket: nil, tag_prefix: "EX", tag_number: 1, queue: :queue.new()}

  def start_link do
    GenServer.start_link(__MODULE__, @initial_state)
  end

  def init(state) do
    opts = [:binary, active: false]
    host = Application.get_env(:eximap, :incoming_mail_server) |> to_charlist
    port = Application.get_env(:eximap, :incoming_port)
    account = Application.get_env(:eximap, :account)
    pass = Application.get_env(:eximap, :password)
    :ssl.start()
    {:ok, socket} = :ssl.connect(host, port, opts)
    state = %{state | socket: socket}

    # todo: parse the server attributes and store them in the state
    imap_receive_raw(socket)

    state = %{state | socket: socket}

    imap_send(%Request{command: "LOGIN", params: [account, pass]}, state)
    imap_receive_raw(socket)
    :ssl.setopts(socket, active: :once)
    {:ok, %{state | tag_number: state.tag_number + 1}}
  end

  def execute(pid, req) do
    GenServer.call(pid, {:command, req})
  end

  def handle_call({:command, req}, from, %{socket: socket, tag_number: tag_number, queue: q} = state) do
    imap_send(req, state)
    {:noreply, %{state | tag_number: tag_number + 1, queue: :queue.in(from, q)}}
  end

  @doc """

  """
  def handle_info({:ssl, socket, msg}, %{socket: socket} = state) do
    # get the first element of the queue and return the new queue
    {{:value, client}, new_queue} = :queue.out(state.queue)

    # get only one message from the imap server
#    :inet.setopts(socket, active: :once)
    :ssl.setopts(socket, active: :once)

    # reply to the calling process
    GenServer.reply(client, msg)

    # return the new state
    {:noreply, %{state | queue: new_queue}}
  end
  def handle_info(resp, %{socket: socket} = state) do
    IO.inspect resp
    {:noreply, state}
  end

  #
  # Private methods
  #

  defp imap_send(req, %{socket: socket} = state) do
    message = encode(state, req.command, req.params)
    imap_send_raw(socket, message)
  end

  defp imap_send_raw(socket, msg) do
    IO.inspect "C: #{msg}"
    :ok = :ssl.send(socket, msg)
  end

  defp imap_receive_raw(socket) do
    {:ok, msg} = :ssl.recv(socket, 0)
    msgs = String.split(msg, "\r\n")
    msgs = Enum.drop msgs, -1
    Enum.map(msgs, &(IO.inspect "S: #{&1}"))
    msgs
  end

  defp encode(%{tag_prefix: tag_prefix, tag_number: tag_number}, command, params) do
    req = %Request{tag: "#{tag_prefix}#{tag_number}", command: command, params: params}
    msg = "#{req.tag} #{req.command} #{Enum.join(req.params, " ")}\r\n"
  end

end