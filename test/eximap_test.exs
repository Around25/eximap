defmodule EximapTest do
  use ExUnit.Case, async: false
  doctest Eximap
  doctest Eximap.Socket
  doctest Eximap.Imap.Client
  doctest Eximap.Imap.Request
end
