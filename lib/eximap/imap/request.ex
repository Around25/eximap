defmodule Eximap.Imap.Request do
  @moduledoc """
  Request formats:

  1. DEFAULT: TAG COMMAND PARAMS \r\n

  """
  defstruct tag: "TAG", command: nil, params: []

  def noop(), do: %Eximap.Imap.Request{command: "NOOP"}
  def list(search\\"", path \\ "%"), do: %Eximap.Imap.Request{command: "LIST", params: [search, path]}
  def logout(), do: %Eximap.Imap.Request{command: "LOGOUT"}
end

defmodule Eximap.Imap.Response do
  @moduledoc ~S"""
  Response formats:

  1. SUCCESS: * OK BODY \r\n
  1. FAILURE: * NO BODY \r\n
  1. SYNTAX ERROR: * BAD BODY \r\n
  1. MORE: + BODY \r\n

  List folders:

      C: 001 LIST "" %
      S: * LIST () "/" Banana
      S: * LIST ...etc...
      S: 001 OK done

  Fetch messages:

      C: 004 FETCH 1:50 ALL
      S: * 1 FETCH ...etc...
      S: 004 OK done

  Fetch inbox:

      C: 003 SELECT INBOX
      S: * 10000 EXISTS
      S: * 80 RECENT
      S: * FLAGS (\Answered \Flagged \Deleted \Draft \Seen)
      S: * OK [UIDVALIDITY 824708485] UID validity status
      S: * OK [UNSEEN 9921] First unseen message
      S: 003 OK [READ-WRITE] SELECT completed
      C: 004 FETCH 9921:* ALL
      ... etc...

      If the server does not return an OK [UNSEEN] response, the client may
      use SEARCH UNSEEN to obtain that value.

  Fetching a Large Body Part in pieces:

      C: 022 FETCH 3 BODY[1]<0.20000>
      S: * 3 FETCH (FLAGS(\Seen) BODY[1]<0> {20000}
      S: ...data...)
      S: 022 OK done
      C: 023 FETCH 3 BODY[1]<20001.20000>
      S: * 3 FETCH (BODY[1]<20001> {20000}
      S: ...data...)
      S: 023 OK done
      C: 024 FETCH 3 BODY[1]<40001.20000>
      ...etc...

  Subscribe:
    SUBSCRIBE, UNSUBSCRIBE, and LSUB

  """
  defstruct tag: nil, status: "OK", body: nil

  def parse("* BAD " <> body), do: %Eximap.Imap.Response{status: "BAD", body: body}
  def parse("* NO " <> body), do: %Eximap.Imap.Response{status: "NO", body: body}
  def parse("* OK " <> body), do: %Eximap.Imap.Response{status: "OK", body: body}
  def parse("+ " <> body), do: %Eximap.Imap.Response{status: "MORE", body: body}
  def parse(tag, message), do: %Eximap.Imap.Response{status: "MORE", body: body}

end