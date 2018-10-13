defmodule RequestTest do
  use ExUnit.Case
  alias Eximap.Imap.Request

  test "NOOP shouldnt have trailing whitespace before CRLF" do
    noop = Request.noop()
    assert Request.raw(noop) == "#{noop.tag} NOOP\r\n"
  end

  test "trailing CRLFs in APPEND params shouldnt be trimmed" do
    text = "Delivered-To: test@localhost\r\n\r\nTest\r\n"
    msize = byte_size(text)
    req = Request.append("INBOX", ["\{#{msize}+\}\r\n", text])
    assert Request.raw(req) == "#{req.tag} APPEND INBOX " <> "\{#{msize}+\}\r\n" <> text <> "\r\n"
  end
end
