defmodule Eximap.Imap.Request do
  @moduledoc """

  """
  defstruct tag: "TAG", command: nil, params: []

  def add_tag(req, tag), do: %Eximap.Imap.Request{req | tag: tag}
  def raw(req), do: "#{req.tag} #{req.command} #{Enum.join(req.params, " ")}\r\n"

  @doc ~S"""
  The NOOP command always succeeds.  It does nothing.

    iex> {:ok, pid} = Eximap.Imap.Client.start_link()
    iex> req = Eximap.Imap.Request.noop()
    iex> Eximap.Imap.Client.execute(pid, req) |> Map.from_struct()
    %{body: ["EX1 OK NOOP completed (0.000 + 0.000 secs)."], error: nil,
    message: "NOOP completed (0.000 + 0.000 secs).", partial: false,
    request: %Eximap.Imap.Request{command: "NOOP", params: [], tag: "EX1"},
    status: "OK"}

  """
  def noop(), do: %Eximap.Imap.Request{command: "NOOP"}

  @doc ~S"""
  The CAPABILITY command requests a listing of capabilities that the server supports.
  The server MUST send a single untagged CAPABILITY response with "IMAP4rev1" as one of the listed
  capabilities before the (tagged) OK response.

  Client and server implementations MUST implement the STARTTLS, LOGINDISABLED, and AUTH=PLAIN capabilities.

    iex> {:ok, pid} = Eximap.Imap.Client.start_link()
    iex> req = Eximap.Imap.Request.capability()
    iex> Eximap.Imap.Client.execute(pid, req)
    %Eximap.Imap.Response{body: ["EX1 OK Capability completed (0.000 + 0.000 secs).",
    "* CAPABILITY IMAP4rev1 LITERAL+ SASL-IR LOGIN-REFERRALS ID ENABLE IDLE SORT SORT=DISPLAY THREAD=REFERENCES THREAD=REFS THREAD=ORDEREDSUBJECT MULTIAPPEND URL-PARTIAL CATENATE UNSELECT CHILDREN NAMESPACE UIDPLUS LIST-EXTENDED I18NLEVEL=1 CONDSTORE QRESYNC ESEARCH ESORT SEARCHRES WITHIN CONTEXT=SEARCH LIST-STATUS BINARY MOVE SPECIAL-USE QUOTA"],
    error: nil, message: "Capability completed (0.000 + 0.000 secs).",
    partial: false,
    request: %Eximap.Imap.Request{command: "CAPABILITY", params: [],
    tag: "EX1"}, status: "OK"}

  """
  def capability(), do: %Eximap.Imap.Request{command: "CAPABILITY"}

  @doc ~S"""
  The AUTHENTICATE command indicates a SASL authentication mechanism to the server. If the server supports the requested
  authentication mechanism, it performs an authentication protocol exchange to authenticate and identify the client.
  """
  def authenticate(mechanism), do: %Eximap.Imap.Request{command: "AUTHENTICATE", params: [mechanism]}

  @doc ~S"""
  The LOGIN command identifies the client to the server and carries
  the plaintext password authenticating this user.
  """
  def login(user, pass), do: %Eximap.Imap.Request{command: "LOGIN", params: [user, pass]}

  @doc ~S"""

    iex> {:ok, pid} = Eximap.Imap.Client.start_link()
    iex> req = Eximap.Imap.Request.list()
    iex> Eximap.Imap.Client.execute(pid, req)
    %Eximap.Imap.Response{body: ["EX1 OK List completed (0.000 + 0.000 secs).",
     "* LIST (\\HasNoChildren) \".\" INBOX",
     "* LIST (\\HasNoChildren \\Sent) \".\" Sent",
     "* LIST (\\HasNoChildren \\Trash) \".\" Trash",
     "* LIST (\\HasNoChildren \\Drafts) \".\" Drafts",
     "* LIST (\\HasNoChildren \\Junk) \".\" Junk"], error: nil,
    message: "List completed (0.000 + 0.000 secs).", partial: false,
    request: %Eximap.Imap.Request{command: "LIST",
     params: ["\"\"", "\"%\""], tag: "EX1"}, status: "OK"}
  """
  def list(reference\\"\"\"", mailbox \\ "\"%\""), do: %Eximap.Imap.Request{command: "LIST", params: [reference, mailbox]}
  def lsub(reference\\"\"\"", mailbox \\ "\"\""), do: %Eximap.Imap.Request{command: "LSUB", params: [reference, mailbox]}

  @doc ~S"""
  The LOGOUT command informs the server that the client is done with
  the connection.  The server MUST send a BYE untagged response
  before the (tagged) OK response, and then close the network
  connection.

    iex> {:ok, pid} = Eximap.Imap.Client.start_link()
    iex> req = Eximap.Imap.Request.logout()
    iex> Eximap.Imap.Client.execute(pid, req)
    %Eximap.Imap.Response{body: ["EX1 OK Logout completed (0.000 + 0.000 secs).",
             "* BYE Logging out"], error: nil,
            message: "Logout completed (0.000 + 0.000 secs).", partial: false,
            request: %Eximap.Imap.Request{command: "LOGOUT", params: [],
             tag: "EX1"}, status: "OK"}
  """
  def logout(), do: %Eximap.Imap.Request{command: "LOGOUT"}

  @doc ~S"""

    iex> {:ok, pid} = Eximap.Imap.Client.start_link()
    iex> req = Eximap.Imap.Request.select("INBOX")
    iex> Eximap.Imap.Client.execute(pid, req)
    %Eximap.Imap.Response{body: ["EX1 OK [READ-WRITE] Select completed (0.000 + 0.000 secs).",
     "* OK [HIGHESTMODSEQ 1] Highest",
     "* OK [UIDNEXT 1] Predicted next UID",
     "* OK [UIDVALIDITY 1512767411] UIDs valid", "* 0 RECENT",
     "* 0 EXISTS",
     "* OK [PERMANENTFLAGS (\\Answered \\Flagged \\Deleted \\Seen \\Draft \\*)] Flags permitted.",
     "* FLAGS (\\Answered \\Flagged \\Deleted \\Seen \\Draft)"],
    error: nil,
    message: "[READ-WRITE] Select completed (0.000 + 0.000 secs).",
    partial: false,
    request: %Eximap.Imap.Request{command: "SELECT", params: ["INBOX"],
     tag: "EX1"}, status: "OK"}
  """
  def select(name), do: %Eximap.Imap.Request{command: "SELECT", params: [name]}
  def subscribe(name), do: %Eximap.Imap.Request{command: "SUBSCRIBE", params: [name]}
  def unsubscribe(name), do: %Eximap.Imap.Request{command: "UNSUBSCRIBE", params: [name]}

  @doc ~S"""

    iex> {:ok, pid} = Eximap.Imap.Client.start_link()
    iex> req = Eximap.Imap.Request.examine("INBOX")
    iex> Eximap.Imap.Client.execute(pid, req)
    %Eximap.Imap.Response{body: ["EX1 OK [READ-ONLY] Examine completed (0.000 + 0.000 secs).",
     "* OK [HIGHESTMODSEQ 1] Highest",
     "* OK [UIDNEXT 1] Predicted next UID",
     "* OK [UIDVALIDITY 1512767411] UIDs valid", "* 0 RECENT",
     "* 0 EXISTS", "* OK [PERMANENTFLAGS ()] Read-only mailbox.",
     "* FLAGS (\\Answered \\Flagged \\Deleted \\Seen \\Draft)"],
    error: nil,
    message: "[READ-ONLY] Examine completed (0.000 + 0.000 secs).",
    partial: false,
    request: %Eximap.Imap.Request{command: "EXAMINE", params: ["INBOX"],
    tag: "EX1"}, status: "OK"}
  """
  def examine(name), do: %Eximap.Imap.Request{command: "EXAMINE", params: [name]}
  def create(name), do: %Eximap.Imap.Request{command: "CREATE", params: [name]}
  def delete(name), do: %Eximap.Imap.Request{command: "DELETE", params: [name]}
  def status(name, opts), do: %Eximap.Imap.Request{command: "STATUS", params: [name, opts]}
  def append(name, [] = opts), do: %Eximap.Imap.Request{command: "APPEND", params: [name, Enum.join(opts, "")]}
  def rename(name, new_name), do: %Eximap.Imap.Request{command: "RENAME", params: [name, new_name]}

  def check(), do: %Eximap.Imap.Request{command: "CHECK", params: []}
  def starttls(), do: %Eximap.Imap.Request{command: "STARTTLS", params: []}
  def close(), do: %Eximap.Imap.Request{command: "CLOSE", params: []}
  def expunge(), do: %Eximap.Imap.Request{command: "EXPUNGE", params: []}
  def search(flags), do: %Eximap.Imap.Request{command: "SEARCH", params: flags}
  def fetch(sequence, flags), do: %Eximap.Imap.Request{command: "FETCH", params: [sequence, flags]}
  def store(sequence, item, value), do: %Eximap.Imap.Request{command: "STORE", params: [sequence, item, value]}
  def copy(sequence, mailbox), do: %Eximap.Imap.Request{command: "COPY", params: [sequence, mailbox]}
  def uid(params), do: %Eximap.Imap.Request{command: "UID", params: params}
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
  defstruct request: nil, body: [], status: "OK", error: nil, message: nil, partial: false

  def parse(resp, line, rest) do
    tag = resp.request.tag
    tag_size = byte_size(tag)
    case line do
      <<^tag::bytes-size(tag_size)>> <> " OK " <> message ->
        {:ok, %Eximap.Imap.Response{resp | body: [line | resp.body], message: message, status: "OK", partial: false}, rest}
      <<^tag::bytes-size(tag_size)>> <> " NO " <> err ->
        {:ok, %Eximap.Imap.Response{resp | body: [line | resp.body], error: err, status: "NO", partial: false}, rest}
      <<^tag::bytes-size(tag_size)>> <> " BAD " <> err ->
        {:ok, %Eximap.Imap.Response{resp | body: [line | resp.body], error: err, status: "BAD", partial: false}, rest}
      _ -> {:ok, %Eximap.Imap.Response{resp | body: [line | resp.body], partial: true}, rest}
    end
  end

#  def parse("* BAD " <> body), do: %Eximap.Imap.Response{status: "BAD", body: body}
#  def parse("* NO " <> body), do: %Eximap.Imap.Response{status: "NO", body: body}
#  def parse("* OK " <> body), do: %Eximap.Imap.Response{status: "OK", body: body}
#  def parse("+ " <> body), do: %Eximap.Imap.Response{status: "MORE", body: body}

end