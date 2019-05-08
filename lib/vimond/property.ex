defimpl Jason.Encoder, for: Vimond.Property do
  def encode(property, opts) do
    %{
      id: property.id,
      name: property.name,
      value: property.value,
      allowUserToUpdate: property.allow_user_to_update
    }
    |> Enum.reject(fn {_key, value} -> value == nil end)
    |> Map.new()
    |> Jason.Encode.map(opts)
  end
end

defmodule Vimond.Property do
  defstruct ~w(id name value allow_user_to_update)a
end
