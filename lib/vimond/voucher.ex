defmodule Vimond.Voucher do
  defstruct [:code, :pool, :product_id, :product_payment_ids, valid: false]
end
