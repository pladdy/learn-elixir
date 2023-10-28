defmodule KV.Registry do
  use GenServer

  # TODO: why not remove `pid` argument and reference KV.Registry in those
  #       places?  Makes the client API simpler and there's less to type...
  #       but what are the consequences?

  @doc """
  Starts the registry.
  """
  # TODO: can make this function name `new` and specify a child_spec
  def start_link(opts) do
    # Since the supervisor starts the registry, name can be omitted
    # opts = Enum.concat(opts, name: KV.Registry) |> Enum.uniq()
    IO.puts("starting a registry #{inspect(opts)}")
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up if bucket pid for `name` exists.
  """
  @spec lookup(pid, any) :: {atom, any}
  def lookup(names, name) do
    GenServer.call(names, {:lookup, name})
  end

  @doc """
  Ensure bucket is created for `name`.
  """
  @spec create(pid, any) :: atom
  def create(names, name) do
    GenServer.cast(names, {:create, name})
  end

  @impl true
  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      {:ok, bucket} = DynamicSupervisor.start_child(KV.Bucket, KV.Bucket)
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)
      {:noreply, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in KV.Registry: #{inspect(msg)}")
    {:noreply, state}
  end
end
