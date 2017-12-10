# Eximap

Eximap is an elixir library that can connect to IMAP servers via TLS and execute commands.

## Motivation

We started working with Elixir this year and we wanted to make an internal CRM, but we could not find any library
that can connect to an IMAP server and load messages and that can be notified of new messages from the server.
All options were in other languages like nodejs, but we since there is a POP3 library in erlang there should be one
for IMAP as well.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `eximap` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:eximap, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/eximap](https://hexdocs.pm/eximap).

