defmodule Vimond.Config do
  defstruct ~w(base_url api_key api_secret)a

  @type t :: %__MODULE__{}
end
