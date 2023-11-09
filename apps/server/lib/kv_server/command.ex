defmodule KVServer.Command do
  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> KVServer.Command.parse "CREATE shopping\r\n"
      {:ok, {:create, "shopping"}}

      iex> KVServer.Command.parse "CREATE shopping  \r\n"
      {:ok, {:create, "shopping"}}

      iex> KVServer.Command.parse "PUT shopping spinach 1\r\n"
      {:ok, {:put, "shopping", "spinach", "1"}}

      iex> KVServer.Command.parse "GET shopping spinach\r\n"
      {:ok, {:get, "shopping", "spinach"}}

      iex> KVServer.Command.parse "DELETE shopping eggs\r\n"
      {:ok, {:delete, "shopping", "eggs"}}

  Unknown commands, or commands with invalid arguments, return an error.

      iex> KVServer.Command.parse "UNKNOWN shopping eggs\r\n"
      {:error, :unknown_command}

      iex> KVServer.Command.parse "GET shopping\r\n"
      {:error, :unknown_command}

  """
  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
      ["DELETE", bucket, key] -> {:ok, {:delete, bucket, key}}
      ["GET", bucket, key] -> {:ok, {:get, bucket, key}}
      ["PUT", bucket, key, value] -> {:ok, {:put, bucket, key, value}}
      _ -> {:error, :unknown_command}
    end
  end

  @doc """
  Run the given command.
  """
  def run(command, pid)

  def run({:create, bucket}, pid) do
    KV.Registry.create(pid, bucket)
    {:ok, "OK\r\n"}
  end

  def run({:create, bucket}) do
    case KV.Router.route(bucket, KV.Registry, :create, [KV.Registry, bucket]) do
      pid when is_pid(pid) -> {:ok, "OK\r\n"}
      _ -> {:error, "FAILED TO CREATE BUCKET"}
    end
  end

  def run({:delete, bucket, key}, pid) do
    lookup(bucket, fn pid ->
      KV.Bucket.delete(pid, key)
      {:ok, "OK\r\n"}
    end)
  end

  def run({:get, bucket, key}, pid) do
    lookup(bucket, fn pid ->
      value = KV.Bucket.get(pid, key)
      {:ok, "#{value}\r\nOK\r\n"}
    end)
  end

  def run({:put, bucket, key, value}, pid) do
    lookup(bucket, fn pid ->
      KV.Bucket.put(pid, key, value)
      {:ok, "OK\r\n"}
    end)
  end

  defp lookup(bucket, callback) do
    case KV.Router.route(bucket, KV.Registry, :lookup, [KV.Registry, bucket]) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end
end
