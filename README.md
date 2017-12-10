# Eximap

Eximap is an elixir library that can connect to IMAP servers via TLS and execute commands.

## Motivation

We started working with Elixir this year and we wanted to make an internal CRM, but we could not find any library
that can connect to an IMAP server and load messages and that can be notified of new messages from the server.
All options were in other languages like nodejs, but we since there is a POP3 library in erlang there should be one
for IMAP as well.

## Roadmap

Completed:
- open an TLS connection to an IMAP server
- login using an email account and password (PLAIN AUTH over TLS)
- Execute commands and return the result as an Elixir structure

Under development:
- Format each response as either a map or a structure for easier interaction.
- Handle binary responses

Planned:
- Handle requests and responses asyncronously

## Development

In order to test and develop the library locally you will need an IMAP server.
One easy way of getting an IMAP server up and running is with Docker.

Make sure you have Docker installed and that the following ports are open and then run this command:
```sh
docker run \
    -p 25:25 \
    -p 80:80 \
    -p 443:443 \
    -p 110:110 \
    -p 143:143 \
    -p 465:465 \
    -p 587:587 \
    -p 993:993 \
    -p 995:995 \
    -v /etc/localtime:/etc/localtime:ro \
    -t analogic/poste.io
```

Once the container is up and running you can create a new email address.
The credentials used in testing this library are:
Host: localhost.dev
Port: 993
User: admin@localhost.dev
Pass: secret

You can run the tests using:
```
mix deps.get
mix test
```

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

