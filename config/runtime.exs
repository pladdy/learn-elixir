import Config

config :kv, :routing_table, [{?a..?z, node()}]

if config_env() == :prod do
  computer_name = String.trim(elem(System.cmd("hostname", ["-s"]), 0))

  config :kv, :routing_table, [
    {?a..?m, :"foo@#{computer_name}"},
    {?n..?z, :"bar@#{computer_name}"}
  ]
end
