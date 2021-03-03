defmodule Vimond.Payment do
  defstruct [:id, :name, :payment_method, :url]
  @type t :: %__MODULE__{}
end
