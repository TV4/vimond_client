defmodule Vimond.ProductGroup do
  defstruct [:id, :name, :description, :sale_status, :sort_index, products: []]
end
