use Mix.Config

config :vimond_client, datetime: DateTime

config :logger, level: (System.get_env("LOG_LEVEL") || "info") |> String.to_existing_atom()

import_config "#{Mix.env()}.exs"
