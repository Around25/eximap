defmodule Eximap.Imap.Client do
  use GenServer
  alias Eximap.Imap.Request
  alias Eximap.Imap.Response
  alias Eximap.Socket

  @moduledoc """
  Imap Client GenServer
  """

  @initial_state %{socket: nil, tag_number: 1}
  @literal ~r/{([0-9]*)}\r\n/s

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
   # IO.inspect "C: #{msg}"
    Socket.send(socket, msg)
  end

  defp imap_receive(socket, req) do
    msg = assemble_msg(socket, req.tag)
    # IO.inspect("R: #{msg}")
    %Response{request: req} |> parse_message(msg)
  end

  # assemble a complete message
  defp assemble_msg(socket, tag), do: assemble_msg(socket, tag, "")

  defp assemble_msg(socket, tag, msg) do
    {:ok, recv} = Socket.recv(socket, 0)
    msg = msg <> recv
    if Regex.match?(~r/^.*#{tag} .*\r\n$/s, msg),
      do: msg,
      else: assemble_msg(socket, tag, msg)
  end

  defp parse_message(resp, ""), do: resp
  defp parse_message(resp, msg) do
    [part, other_parts] = get_msg_part(msg)
    {:ok, resp, other_parts} = Response.parse(resp, part, other_parts)
    if resp.partial, do: parse_message(resp, other_parts), else: resp
  end

  # get [message part, other message parts] that recognises {size}\r\n literals
  defp get_msg_part(msg), do: get_msg_part("", msg)
  defp get_msg_part(part, other_parts) do
    if other_parts =~ @literal do
      [_match | [size]] = Regex.run(@literal, other_parts)
      size = String.to_integer(size)
      [head, tail] = String.split(other_parts, @literal, parts: 2)
      # literal = for i <- 0..(size - 1), do: Enum.at(String.codepoints(tail), i)
      # Performace boost.  Large messages and attachments killed this and took > 2 minutes for a 40K attachment.
      cp=String.codepoints(tail)
      {literal, _post_literal_cp} = Enum.split(cp,size)
      literal = to_string(literal)
      {_, post_literal} = String.split_at(tail, String.length(literal))

      case post_literal do
        "\r\n" <> next -> [part <> head <> literal, next]
        _ -> get_msg_part(part <> head <> literal, post_literal)
      end
    else
      [h, t] = String.split(other_parts, "\r\n", parts: 2)
      [part <> h, t]
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
