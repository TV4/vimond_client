defmodule Vimond.Client.PaymentMethodsTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  import Mox
  import ExUnit.CaptureLog

  setup :verify_on_exit!

  @config %Vimond.Config{base_url: "https://vimond-rest-api.example.com/api/platform/"}

  test "with several payment methods" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "productgroup/0/products/1491/productPayments",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %HTTPotion.Response{
        status_code: 200,
        body:
          Jason.encode!(%{
            productPaymentList: [
              %{
                uri: "/api/cse/productgroup/0/products/1491/productPayments/2793",
                description: "Standard Klarna Test",
                enabled: true,
                id: 2793,
                initPrice: 0,
                discountedPrice: 0,
                recurringPrice: 139,
                recurringDiscountedPrice: 139,
                paymentProviderId: 34,
                productId: 1491,
                sortIndex: 0,
                productPaymentStatus: "ENABLED",
                paymentObjectUri: %{
                  uri: "/api/cse/productgroup/0/products/1491/productPayments/2793/payment"
                },
                autorenewWarningChannel: "EMAIL",
                autoRenewWarningEnabled: false,
                initPeriod: "PT1209600S"
              },
              %{
                uri: "/api/cse/productgroup/0/products/1491/productPayments/2798",
                description: "Standard Klarna Direkt",
                enabled: true,
                id: 2798,
                initPrice: 0,
                discountedPrice: 0,
                recurringPrice: 139,
                recurringDiscountedPrice: 139,
                paymentProviderId: 35,
                productId: 1491,
                sortIndex: 0,
                productPaymentStatus: "ENABLED",
                paymentObjectUri: %{
                  uri: "/api/cse/productgroup/0/products/1491/productPayments/2798/payment"
                },
                autorenewWarningChannel: "EMAIL",
                autoRenewWarningEnabled: false,
                initPeriod: "PT1209600S"
              },
              %{
                uri: "/api/cse/productgroup/0/products/1491/productPayments/2712",
                description: "Standard",
                enabled: true,
                id: 2712,
                initPrice: 0,
                discountedPrice: 0,
                recurringPrice: 139,
                recurringDiscountedPrice: 139,
                paymentProviderId: 27,
                productId: 1491,
                sortIndex: 0,
                productPaymentStatus: "DISABLED",
                paymentObjectUri: %{
                  uri: "/api/cse/productgroup/0/products/1491/productPayments/2712/payment"
                },
                autorenewWarningChannel: "EMAIL",
                autoRenewWarningEnabled: false,
                initPeriod: "PT1209600S"
              },
              %{
                uri: "/api/cse/productgroup/0/products/1491/productPayments/5300",
                enabled: true,
                id: 5300,
                initPrice: 0,
                discountedPrice: 0,
                recurringPrice: 139,
                recurringDiscountedPrice: 139,
                paymentProviderId: 33,
                productId: 1491,
                sortIndex: 0,
                productPaymentStatus: "HIDDEN",
                paymentObjectUri: %{
                  uri: "/api/cse/productgroup/0/products/1491/productPayments/5300/payment"
                },
                autorenewWarningChannel: "EMAIL",
                autoRenewWarningEnabled: false,
                initPeriod: "PT1209600S"
              }
            ]
          }),
        headers: %HTTPotion.Headers{
          hdrs: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
        }
      }
    end)

    assert payment_methods(1491, @config) ==
             {:ok,
              [
                %{
                  auto_renew_warning_enabled: false,
                  autorenew_warning_channel: "EMAIL",
                  description: "Standard Klarna Test",
                  discounted_price: 0,
                  enabled: true,
                  id: 2793,
                  init_price: 0,
                  init_period: "PT1209600S",
                  payment_object_uri: "/api/cse/productgroup/0/products/1491/productPayments/2793/payment",
                  payment_provider_id: 34,
                  product_id: 1491,
                  product_payment_status: "ENABLED",
                  recurring_discounted_price: 139,
                  recurring_price: 139,
                  sort_index: 0,
                  uri: "/api/cse/productgroup/0/products/1491/productPayments/2793"
                },
                %{
                  auto_renew_warning_enabled: false,
                  autorenew_warning_channel: "EMAIL",
                  description: "Standard Klarna Direkt",
                  discounted_price: 0,
                  enabled: true,
                  id: 2798,
                  init_price: 0,
                  init_period: "PT1209600S",
                  payment_object_uri: "/api/cse/productgroup/0/products/1491/productPayments/2798/payment",
                  payment_provider_id: 35,
                  product_id: 1491,
                  product_payment_status: "ENABLED",
                  recurring_discounted_price: 139,
                  recurring_price: 139,
                  sort_index: 0,
                  uri: "/api/cse/productgroup/0/products/1491/productPayments/2798"
                },
                %{
                  auto_renew_warning_enabled: false,
                  autorenew_warning_channel: "EMAIL",
                  description: "Standard",
                  discounted_price: 0,
                  enabled: true,
                  id: 2712,
                  init_price: 0,
                  init_period: "PT1209600S",
                  payment_object_uri: "/api/cse/productgroup/0/products/1491/productPayments/2712/payment",
                  payment_provider_id: 27,
                  product_id: 1491,
                  product_payment_status: "DISABLED",
                  recurring_discounted_price: 139,
                  recurring_price: 139,
                  sort_index: 0,
                  uri: "/api/cse/productgroup/0/products/1491/productPayments/2712"
                },
                %{
                  auto_renew_warning_enabled: false,
                  autorenew_warning_channel: "EMAIL",
                  description: nil,
                  discounted_price: 0,
                  enabled: true,
                  id: 5300,
                  init_price: 0,
                  init_period: "PT1209600S",
                  payment_object_uri: "/api/cse/productgroup/0/products/1491/productPayments/5300/payment",
                  payment_provider_id: 33,
                  product_id: 1491,
                  product_payment_status: "HIDDEN",
                  recurring_discounted_price: 139,
                  recurring_price: 139,
                  sort_index: 0,
                  uri: "/api/cse/productgroup/0/products/1491/productPayments/5300"
                }
              ]}
  end

  test "without payment methods" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "productgroup/0/products/1491/productPayments",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %HTTPotion.Response{
        status_code: 200,
        body:
          Jason.encode!(%{
            productPaymentList: []
          }),
        headers: %HTTPotion.Headers{
          hdrs: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
        }
      }
    end)

    assert payment_methods(1491, @config) == {:ok, []}
  end

  test "with error from Vimond" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "productgroup/0/products/1491/productPayments",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %HTTPotion.Response{status_code: 500}
    end)

    assert capture_log(fn ->
             assert payment_methods(1491, @config) == {:error, "Failed to fetch payment methods"}
           end) =~ "handle_payment_methods_response: Unexpected response"
  end
end
