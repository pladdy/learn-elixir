defmodule KV.RouterTest do
  use ExUnit.Case, async: true

  @tag :distributed
  test "route requests across nodes" do
    computer_name = String.trim(elem(System.cmd("hostname", ["-s"]), 0))

    assert KV.Router.route("hello", Kernel, :node, []) == :"foo@#{computer_name}"
    assert KV.Router.route("world", Kernel, :node, []) == :"bar@#{computer_name}"
  end

  test "raise on unknown entries" do
    assert_raise RuntimeError, ~r/failed to find/, fn ->
      KV.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end
