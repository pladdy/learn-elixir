defmodule KVServerTest do
  use ExUnit.Case
  @moduletag :capture_log

  doctest KVServer

  setup do
    Application.stop(:kv)
    :ok = Application.start(:kv)
  end

  setup do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 4040, opts)
    %{socket: socket}
  end

  @tag :distributed
  test "server interaction", %{socket: socket} do
    # without \r\n in the command, the server timesout
    assert send_and_recv(socket, "UNKNOWN shopping\r\n") ==
             "Unknown command\r\n"

    assert send_and_recv(socket, "GET foo bar\r\n") ==
             "Not found\r\n"

    assert send_and_recv(socket, "CREATE shopping\r\n") ==
             "OK\r\n"

    assert send_and_recv(socket, "PUT shopping spinach 3\r\n") ==
             "OK\r\n"

    assert send_and_recv(socket, "GET shopping spinach\r\n") == "3\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"

    assert send_and_recv(socket, "DELETE shopping spinach\r\n") ==
             "OK\r\n"

    assert send_and_recv(socket, "GET shopping spinach\r\n") == "\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"
  end

  defp send_and_recv(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end
end

defmodule KVServer.CommandTest do
  use ExUnit.Case, async: true
  doctest KVServer.Command
end
