import Config

config :vimond_client, datetime: DateTime

config :logger, level: (System.get_env("LOG_LEVEL") || "info") |> String.to_existing_atom()

if config_env() == :test do
  import_config "test.exs"
end
