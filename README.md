# Eximap

[![Build Status](https://travis-ci.org/Around25/eximap.svg?branch=master)](https://travis-ci.org/Around25/eximap)
[![Hex Version](https://img.shields.io/hexpm/v/eximap.svg)](https://hex.pm/packages/eximap)
[![Coverage Status](https://coveralls.io/repos/github/Around25/eximap/badge.svg?branch=master)](https://coveralls.io/github/Around25/eximap?branch=master)

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
- Format each response as either a map or a structure for easier interaction.

Under development:
- Handle binary responses

Planned:
- Handle requests and responses asyncronously

## Development

In order to test and develop the library locally you will need an IMAP server.
One easy way of getting an IMAP server up and running is with Docker.

Make sure you have Docker installed and that the following ports are open and then run this command:
```sh
docker run -d -p 25:25 -p 80:80 -p 443:443 -p 110:110 -p 143:143 -p 465:465 -p 587:587 -p 993:993 -p 995:995 -v /etc/localtime:/etc/localtime:ro -t analogic/poste.io
curl --insecure --request POST --url https://localhost/admin/install/server --form install[hostname]=127.0.0.1 --form install[superAdmin]=admin@127.0.0.1 --form install[superAdminPassword]=admin
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

## Usage

First configure the connection to your IMAP server:

```yaml
config :eximap,
  account: "admin@localhost.dev",
  password: "secret",
  use_ssl: true,
  incoming_mail_server: "localhost.dev",
  incoming_port: 993, #TLS
```

Then start the connection to the server by calling the start_link method and execute commands.

```bash
iex> {:ok, pid} = Eximap.Imap.Client.start_link()
iex> req = Eximap.Imap.Request.noop()
iex> Eximap.Imap.Client.execute(pid, req) |> Map.from_struct()
%{body: [%{}], error: nil,
         message: "NOOP completed (0.000 + 0.000 secs).", partial: false,
         request: %Eximap.Imap.Request{command: "NOOP", params: [],
          tag: "EX1"}, status: "OK"}
```

## Installation

Eximap in [available in Hex](https://hex.pm/docs/publish) and can be installed
by adding `eximap` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:eximap, "~> 0.1.1-dev"}
  ]
end
```

The documentation is available here: https://hexdocs.pm/eximap/readme.html
