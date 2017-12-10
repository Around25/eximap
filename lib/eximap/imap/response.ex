defmodule Eximap.Imap.Response do
  @moduledoc ~S"""
  Parse responses returned by the IMAP server and convert them to a structured format
  """
  defstruct request: nil, body: [], status: "OK", error: nil, message: nil, partial: false

#  @response_codes [
#    "ALERT", "BADCHARSET", "CAPABILITY", "PARSE", "PERMANENTFLAGS", "READ-ONLY", "READ-WRITE",
#    "TRYCREATE", "UIDNEXT", "UIDVALIDITY", "UNSEEN"
#  ]

  def parse(resp, line, rest) do
    parse_tag(resp, line, rest)
  end

  defp parse_tag(resp, line, rest) do
    tag = resp.request.tag
    tag_size = byte_size(tag)
    case line do
      "* " <> message ->
        parse_message("untagged", resp, message, rest)
      <<^tag::bytes-size(tag_size)>> <> " " <> message ->
        parse_message("tagged", resp, message, rest)
    end
  end

  defp parse_message("untagged", resp, msg, rest) do
    [type | [msg]] = String.split(msg, " ", parts: 2)
    {:ok, append_to_response(resp, item: %{type: type, message: msg}), rest}
  end

  defp parse_message("tagged", resp, "NO " <> msg, rest), do: {:ok, append_to_response(resp, status: "NO", partial: false, message: msg), rest}
  defp parse_message("tagged", resp, "BAD " <> msg, rest), do: {:ok, append_to_response(resp, status: "BAD", partial: false, message: msg), rest}
  defp parse_message("tagged", resp, "OK " <> msg, rest), do: {:ok, append_to_response(resp, status: "OK", partial: false, message: msg), rest}
  defp parse_message("tagged", resp, msg, rest), do: {:ok, append_to_response(resp, status: "UNKNOWN", partial: false, message: msg), rest}

  defp append_to_response(resp, opts) do
    status = Keyword.get(opts, :status, "OK")
    item = Keyword.get(opts, :item, %{})
    message = Keyword.get(opts, :message, "")
    partial = Keyword.get(opts, :partial, true)
    %Eximap.Imap.Response{resp | body: [item | resp.body], message: message, status: status, partial: partial}
  end
end