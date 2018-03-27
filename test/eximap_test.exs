defmodule EximapTest do
  use ExUnit.Case, async: false
  alias Eximap.Imap.{Client, Request}
  doctest Eximap
  doctest Eximap.Socket
  doctest Eximap.Imap.Client
  doctest Eximap.Imap.Request
  doctest Eximap.Imap.Response

  @large_mailbox_message_count 500

  setup_all do
    {:ok, pid} = Client.start_link()
    [pid: pid]
  end


  test "Test searching a mailbox with at least #{@large_mailbox_message_count} emails", state do
    pid = state.pid
    ensure_large_mailbox(pid, "INBOX")
    execute!(pid, Request.search(["ALL"]))
  end

  test "Test parsing LITERALs by fetching RECEIVED headers", state do
    pid = state.pid
    ensure_large_mailbox(pid, "INBOX")
    resp = execute!(pid, Request.search(["ALL"]))
    seqs = String.split(hd(tl(resp.body)).message, " ")
    fields = "BODY.PEEK[HEADER.FIELDS (RECEIVED)]"
    execute!(pid, Request.fetch(hd(seqs), fields)).body
  end

  # ensure mailbox with at least @large_mailbox_message_count emails
  defp ensure_large_mailbox(pid, name) do
    count = select_mailbox!(pid, name)
    fill = @large_mailbox_message_count - count
    if 0 < fill do
      mime = File.read!("test/test_message.eml")
      msize = byte_size(mime)
      for _ <- 1..fill,  do:
        execute!(pid, Request.append("INBOX", ["\{#{msize}+\}\r\n", mime]))
    end
  end


  # execute with exception on error
  defp execute!(pid, req) do
    resp = Client.execute(pid, req)
    if (assert resp.error == nil), do: resp
  end

  # select and return size of mallbox
  defp select_mailbox!(pid, name) do
    msg = execute!(pid, Request.select(name)).body
    |> Enum.filter(&(&1 != %{} && &1.message == "EXISTS"))
    case msg do
      %{} -> 0
      _ -> String.to_integer(hd(msg).type)
    end
  end
end
