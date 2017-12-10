defmodule Eximap.Socket do
  @moduledoc """
  A socket module that abstracts away the type of the connection it has with a server.
  """

  @doc """
  Connect to a node using either :ssl or :gen_tcp
  """
  def connect(false, host, port, opts), do: :gen_tcp.connect(host, port, opts)
  def connect(true = _usessl, host, port, opts) do
    :ssl.start()
    :ssl.connect(host, port, opts)
  end

  @doc """
  Set options for the socket based on the type of the connection
  """
  def setopts({:sslsocket, _, _}= socket, opts), do: :ssl.setopts(socket, opts)
  def setopts({:gen_tcp, _, _, _}= socket, opts), do: :inet.setopts(socket, opts)

  @doc """
  Send some data to the socket abstracting the type of the socket away
  """
  def send({:sslsocket, _, _}= socket, msg), do: :ssl.send(socket, msg)
  def send({:gen_tcp, _, _, _}= socket, msg), do: :gen_tcp.send(socket, msg)

  @doc """
  Receive data from the socket
  """
  def recv({:sslsocket, _, _}= socket, length), do: :ssl.recv(socket, length)
  def recv({:gen_tcp, _, _, _}= socket, length), do: :gen_tcp.recv(socket, length)
  def recv({:sslsocket, _, _}= socket, length, timeout), do: :ssl.recv(socket, length, timeout)
  def recv({:gen_tcp, _, _, _}= socket, length, timeout), do: :gen_tcp.recv(socket, length, timeout)

end