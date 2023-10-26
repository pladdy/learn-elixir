defmodule KV.Bucket do
  use Agent

  @doc """
  Create a new bucket.
  """
  # TODO: can make this function name `new` and specify a child_spec
  @spec start_link(list) :: {:ok, pid}
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Delete value from bucket.

  Returns the value.
  """
  @spec delete(pid, any) :: any
  def delete(bucket, key) do
    # Agent.get_and_update(bucket, &Map.pop(&1, key))
    Agent.get_and_update(bucket, fn dict -> Map.pop(dict, key) end)
  end

  @doc """
  Get value from a bucket.
  """
  @spec get(pid, any) :: any
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the 'value' for the given 'key' in the bucket.
  """
  @spec put(pid, any, any) :: :ok
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end
end
