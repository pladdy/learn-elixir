defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(KV.Registry)
    %{registry: registry}
  end

  test "spawns bucket", %{registry: registry} do
    assert KV.Registry.lookup(registry, "cookie") == :error

    KV.Registry.create(registry, "cookie")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "cookie")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "removes bucket on exit", %{registry: registry} do
    KV.Registry.create(registry, "cookies")
    {:ok, bucket} = KV.Registry.lookup(registry, "cookies")
    Agent.stop(bucket)
    assert KV.Registry.lookup(registry, "cookies") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, "veggies")
    {:ok, bucket} = KV.Registry.lookup(registry, "veggies")

    Agent.stop(bucket, :shutdown)
    assert KV.Registry.lookup(registry, "veggies") == :error
  end
end
