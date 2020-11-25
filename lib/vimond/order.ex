defmodule Vimond.Order do
  defstruct ~w(order_id product_id product_group_id product_payment_id asset_id referrer end_date)a

  @type t :: %__MODULE__{end_date: DateTime.t()}
end
