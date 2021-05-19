defmodule Vimond.Config do
  defstruct ~w(base_url api_key api_secret)a

  @type t :: %__MODULE__{}

  @doc "Read configuration from environment. Helper for manual testing of Vimond Client"
  def from_environment() do
    %__MODULE__{
      base_url: System.fetch_env!("VIMOND_BASE_URL"),
      api_key: System.fetch_env!("VIMOND_API_KEY"),
      api_secret: System.fetch_env!("VIMOND_API_SECRET")
    }
  end
end
