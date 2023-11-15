defmodule KV.Router do
  @doc """
  Dispatch given `mod`, `fun`, `args` request to a node based on the `bucket`.
  """
  def route(bucket, mod, fun, args) do
    first = :binary.first(bucket)

    entry =
      Enum.find(table(), fn {enum, _node} ->
        first in enum
      end) || no_entry_error(bucket)

    if elem(entry, 1) == node() do
      apply(mod, fun, args)
    else
      {KV.RouterTasks, elem(entry, 1)}
      |> Task.Supervisor.async(KV.Router, :route, [bucket, mod, fun, args])
      |> Task.await()
    end
  end

  defp no_entry_error(bucket) do
    raise "failed to find entry #{inspect(bucket)} in table #{inspect(table())}"
  end

  defp table() do
    Application.fetch_env!(:kv, :routing_table)
  end
end
