defmodule Vimond.Voucher do
  defstruct [
    :code,
    :pool,
    :usages,
    :start_at,
    :end_at,
    :product_id
  ]
end
