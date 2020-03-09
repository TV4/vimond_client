defmodule Vimond.Client.ProductPaymentTest do
  use ExUnit.Case, async: true
  alias Vimond.Client
  import Hammox
  import ExUnit.CaptureLog

  setup :verify_on_exit!

  @config %Vimond.Config{base_url: "https://vimond-rest-api.example.com/api/platform/"}
  describe "product payments without voucher" do
    test "with several product payments" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "productgroup/0/products/1491/productPayments",
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8"
                         ],
                         @config ->
        %Vimond.Response{
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
          headers: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
        }
      end)

      assert Client.product_payments(1491, @config) ==
               {:ok,
                [
                  %Vimond.ProductPayment{
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
                  %Vimond.ProductPayment{
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
                  %Vimond.ProductPayment{
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
                  %Vimond.ProductPayment{
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

    test "without product payments" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "productgroup/0/products/1491/productPayments",
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8"
                         ],
                         @config ->
        %Vimond.Response{
          status_code: 200,
          body:
            Jason.encode!(%{
              productPaymentList: []
            }),
          headers: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
        }
      end)

      assert Client.product_payments(1491, @config) == {:ok, []}
    end

    test "with error from Vimond" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "productgroup/0/products/1491/productPayments",
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8"
                         ],
                         @config ->
        %Vimond.Response{status_code: 500}
      end)

      assert capture_log(fn ->
               assert Client.product_payments(1491, @config) == {:error, "Failed to fetch product payments"}
             end) =~ "handle_product_payments_response: Unexpected response"
    end
  end

  describe "product methods with voucher" do
    test "with a valid voucher" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "productgroup/0/products/1491/productPayments",
                         %{voucherCode: "existing%20voucher"},
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8"
                         ],
                         @config ->
        %Vimond.Response{
          status_code: 200,
          body:
            Jason.encode!(%{
              productPaymentList: [
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
                }
              ]
            }),
          headers: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
        }
      end)

      assert Client.product_payments(1491, "existing%20voucher", @config) ==
               {:ok,
                [
                  %Vimond.ProductPayment{
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
                  %Vimond.ProductPayment{
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
                  }
                ]}
    end

    test "with an invalid voucher" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "productgroup/0/products/1491/productPayments",
                         %{voucherCode: "invalid-voucher"},
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8"
                         ],
                         @config ->
        %Vimond.Response{status_code: 404}
      end)

      assert capture_log(fn ->
               assert Client.product_payments(1491, "invalid-voucher", @config) ==
                        {:error, "Failed to fetch product payments"}
             end) =~ "handle_product_payments_response: Invalid voucher"
    end
  end

  describe "product payment with product payment id" do
    test "with existing product payment" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "productgroup/0/products/0/productPayments/5960",
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8"
                         ],
                         @config ->
        %Vimond.Response{
          body:
            %{
              "autoRenewWarningEnabled" => false,
              "autorenewWarningChannel" => "EMAIL",
              "enabled" => true,
              "id" => 5960,
              "initPeriod" => "PT864000000S",
              "initPrice" => 0.0,
              "paymentObjectUri" => %{
                "uri" => "/api/cse/productgroup/0/products/2861/productPayments/5960/payment"
              },
              "paymentProviderId" => 50,
              "productId" => 2861,
              "productPaymentStatus" => "ENABLED",
              "sortIndex" => 0,
              "uri" => "/api/cse/productgroup/0/products/2861/productPayments/5960"
            }
            |> Jason.encode!(),
          status_code: 200
        }
      end)

      assert Client.product_payment(5960, @config) ==
               {:ok,
                %Vimond.ProductPayment{
                  auto_renew_warning_enabled: false,
                  autorenew_warning_channel: "EMAIL",
                  enabled: true,
                  id: 5960,
                  init_period: "PT864000000S",
                  init_price: 0.0,
                  payment_object_uri: "/api/cse/productgroup/0/products/2861/productPayments/5960/payment",
                  payment_provider_id: 50,
                  product_id: 2861,
                  product_payment_status: "ENABLED",
                  sort_index: 0,
                  uri: "/api/cse/productgroup/0/products/2861/productPayments/5960"
                }}
    end

    test "when it does not exist" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "productgroup/0/products/0/productPayments/5960",
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8"
                         ],
                         @config ->
        %Vimond.Response{
          body:
            %{
              "error" => %{
                "code" => "PRODUCT_PAYMENT_NOT_FOUND",
                "description" => "No ProductPayment with id 5960",
                "id" => "1081",
                "reference" => "8ec3b887078043c4"
              }
            }
            |> Jason.encode!(),
          status_code: 404
        }
      end)

      assert Client.product_payment(5960, @config) ==
               {:error, %{type: :product_payment_not_found, source_errors: ["No ProductPayment with id 5960"]}}
    end
  end
end
