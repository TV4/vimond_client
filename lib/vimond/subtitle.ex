defmodule Vimond.Subtitle do
  defstruct [:asset_id, :content_type, :id, :locale, :name, :type, :uri]

  @type t :: %__MODULE__{}
end
