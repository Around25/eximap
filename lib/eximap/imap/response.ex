defmodule Eximap.Imap.Response do
  @moduledoc ~S"""

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