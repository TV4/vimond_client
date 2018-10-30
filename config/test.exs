use Mix.Config

config :vimond_client,
  vimond_base_url: "https://vimond-rest-api.example.com/api/platform/",
  vimond_api_key: "key",
  vimond_api_secret: "secret",
  datetime: FakeDateTime

config :logger, level: :warn
