defmodule Vimond.ProductPayment do
  defstruct [
    :auto_renew_warning_enabled,
    :autorenew_warning_channel,
    :description,
    :discounted_price,
    :enabled,
    :id,
    :init_period,
    :init_price,
    :payment_object_uri,
    :payment_provider_id,
    :product_id,
    :product_payment_status,
    :recurring_discounted_price,
    :recurring_price,
    :sort_index,
    :uri
  ]
end
