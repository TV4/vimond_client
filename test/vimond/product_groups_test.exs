defmodule Vimond.Client.ProductGroupsTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  import Mox

  setup :verify_on_exit!

  @config %Vimond.Config{base_url: "https://vimond-rest-api.example.com/api/platform/"}

  describe "product groups" do
    test "succeeds" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "productgroup",
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8"
                         ],
                         @config ->
        %Vimond.Response{
          status_code: 200,
          body:
            Jason.encode!(%{
              productGroups: [
                %{
                  id: 2075,
                  name: "C More Premium",
                  description: "C More TV4",
                  saleStatus: "ENABLED",
                  sortIndex: 0,
                  productsUri: %{products: []}
                },
                %{
                  id: 2060,
                  name: "C More",
                  description: "C More",
                  saleStatus: "ENABLED",
                  sortIndex: 1,
                  productsUri: %{products: []}
                }
              ]
            }),
          headers: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
        }
      end)

      assert Vimond.Client.product_groups(@config) ==
               {:ok,
                [
                  %Vimond.ProductGroup{
                    id: 2075,
                    name: "C More Premium",
                    description: "C More TV4",
                    sale_status: "ENABLED",
                    sort_index: 0,
                    products: []
                  },
                  %Vimond.ProductGroup{
                    id: 2060,
                    name: "C More",
                    description: "C More",
                    sale_status: "ENABLED",
                    sort_index: 1,
                    products: []
                  }
                ]}
    end

    test "with error from Vimond" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "productgroup",
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8"
                         ],
                         @config ->
        %Vimond.Response{status_code: 500}
      end)

      assert capture_log(fn ->
               assert Vimond.Client.product_groups(@config) == {:error, "Failed to fetch product groups"}
             end) =~ "handle_product_groups_response: Unexpected response"
    end
  end

  describe "product groups with query" do
    test "succeeds" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "productgroup",
                         %{expand: "products,productpayments"},
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8"
                         ],
                         @config ->
        %Vimond.Response{
          body:
            %{
              productGroups: [
                %{
                  accessType: "PAID",
                  categoriesUri: %{
                    uri: "/api/cse/productgroup/1235/categories"
                  },
                  checkAccessForProgramRelations: false,
                  description: "C More TV4",
                  id: 1235,
                  metadata: %{
                    empty: true,
                    entries: %{},
                    uri: "/api/metadata/productgroup/1235"
                  },
                  name: "C More TV4",
                  productGroupAccessesUri: %{
                    uri: "/api/cse/productgroup/1235/accesses"
                  },
                  productsUri: %{
                    products: [
                      %{
                        comment: "Buy: C More TV4. Ordinarie produkt.",
                        currency: "SEK",
                        enabled: true,
                        id: 1491,
                        minimumPeriods: 0,
                        paymentPlan: %{
                          id: 2060,
                          name: "Ordinarie",
                          paymentType: "SUBSCRIPTION",
                          period: "PT2592000S"
                        },
                        price: 139.0,
                        productGroupId: 1235,
                        productPayments: %{
                          productPaymentList: [
                            %{
                              autoRenewWarningEnabled: false,
                              autorenewWarningChannel: "EMAIL",
                              description: "Standard",
                              enabled: true,
                              id: 2712,
                              initPeriod: "PT1209600S",
                              initPrice: 0.0,
                              paymentObjectUri: %{},
                              paymentProviderId: 27,
                              productId: 1491,
                              productPaymentStatus: "ENABLED",
                              sortIndex: 0
                            },
                            %{
                              autoRenewWarningEnabled: false,
                              autorenewWarningChannel: "EMAIL",
                              description: "Standard Klarna Direkt",
                              enabled: true,
                              id: 2798,
                              initPeriod: "PT1209600S",
                              initPrice: 0.0,
                              paymentObjectUri: %{},
                              paymentProviderId: 35,
                              productId: 1491,
                              productPaymentStatus: "ENABLED",
                              sortIndex: 1
                            }
                          ]
                        },
                        productPaymentsUri: %{
                          uri: "/api/cse/productgroup/1235/products/1491/productPayments"
                        },
                        productStatus: "ENABLED",
                        sortIndex: 0,
                        uri: "/api/cse/productgroup/1235/products/1491"
                      }
                    ]
                  },
                  saleStatus: "ENABLED",
                  sortIndex: 0,
                  uri: "/api/cse/productgroup/1235"
                }
              ]
            }
            |> Jason.encode!(),
          headers: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"},
          status_code: 200
        }
      end)

      assert Vimond.Client.product_groups(%{expand: "products,productpayments"}, @config) ==
               {:ok,
                [
                  %Vimond.ProductGroup{
                    id: 1235,
                    name: "C More TV4",
                    description: "C More TV4",
                    sale_status: "ENABLED",
                    sort_index: 0,
                    products: [
                      %Vimond.Product{
                        id: 1491,
                        currency: "SEK",
                        enabled: true,
                        minimum_periods: 0,
                        price: 139.0,
                        product_group_id: 1235,
                        product_payments_uri: "/api/cse/productgroup/1235/products/1491/productPayments",
                        product_status: "ENABLED",
                        sort_index: 0,
                        payment_plan: %Vimond.PaymentPlan{
                          name: "Ordinarie",
                          payment_type: "SUBSCRIPTION",
                          period: "PT2592000S"
                        },
                        product_payments: [
                          %Vimond.ProductPayment{
                            auto_renew_warning_enabled: false,
                            autorenew_warning_channel: "EMAIL",
                            description: "Standard",
                            enabled: true,
                            id: 2712,
                            init_period: "PT1209600S",
                            init_price: 0.0,
                            payment_provider_id: 27,
                            product_id: 1491,
                            product_payment_status: "ENABLED",
                            sort_index: 0
                          },
                          %Vimond.ProductPayment{
                            auto_renew_warning_enabled: false,
                            autorenew_warning_channel: "EMAIL",
                            description: "Standard Klarna Direkt",
                            enabled: true,
                            id: 2798,
                            init_period: "PT1209600S",
                            init_price: 0.0,
                            payment_provider_id: 35,
                            product_id: 1491,
                            product_payment_status: "ENABLED",
                            sort_index: 1
                          }
                        ]
                      }
                    ]
                  }
                ]}
    end
  end
end
