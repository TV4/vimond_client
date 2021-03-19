defmodule Vimond.Voucher do
  defstruct [
    :code,
    :pool,
    :pool_name,
    :product_id,
    :product_payment_ids
  ]

  @type t :: %__MODULE__{}
end
