defmodule Vimond.Product do
  defstruct [
    :id,
    :currency,
    :description,
    :enabled,
    :minimum_periods,
    :price,
    :product_group_id,
    :product_payments_uri,
    :product_status,
    payment_plan: %Vimond.PaymentPlan{}
  ]
end
