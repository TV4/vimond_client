defmodule Vimond.Client.ProductsTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  import Mox
  import ExUnit.CaptureLog

  setup :verify_on_exit!

  @config %Vimond.Config{base_url: "https://vimond-rest-api.example.com/api/platform/"}

  describe "products with product group id" do
    test "with a list of products" do
      Vimond.HTTPClientMock
      |> expect(
        :get,
        fn "productgroup/1235/products",
           [
             Accept: "application/json; v=3; charset=UTF-8",
             "Content-Type": "application/json; v=3; charset=UTF-8"
           ],
           @config ->
          %Vimond.Response{
            status_code: 200,
            body:
              Jason.encode!(%{
                products: [
                  %{
                    uri: "/api/cse/productgroup/1235/products/1491",
                    paymentPlan: %{
                      id: 2060,
                      name: "Ordinarie",
                      paymentType: "SUBSCRIPTION",
                      period: "PT2592000S"
                    },
                    enabled: true,
                    minimumPeriods: 0,
                    price: 139,
                    productGroupId: 1235,
                    sortIndex: 1,
                    productPaymentsUri: %{
                      uri: "/api/cse/productgroup/1235/products/1491/productPayments"
                    },
                    id: 1491,
                    currency: "SEK",
                    productStatus: "ENABLED",
                    comment: "Buy: C More TV4. Ordinarie produkt.",
                    productPayments: %{productPaymentList: []}
                  }
                ]
              }),
            headers: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
          }
        end
      )

      assert products("1235", @config) ==
               {:ok,
                %{
                  products: [
                    %Vimond.Product{
                      id: 1491,
                      currency: "SEK",
                      description: nil,
                      enabled: true,
                      minimum_periods: 0,
                      payment_plan: %Vimond.PaymentPlan{
                        name: "Ordinarie",
                        payment_type: "SUBSCRIPTION",
                        period: "PT2592000S"
                      },
                      price: 139,
                      product_group_id: 1235,
                      product_payments_uri: "/api/cse/productgroup/1235/products/1491/productPayments",
                      product_status: "ENABLED",
                      sort_index: 1
                    }
                  ]
                }}
    end

    test "with no products" do
      Vimond.HTTPClientMock
      |> expect(
        :get,
        fn "productgroup/1083/products",
           [
             Accept: "application/json; v=3; charset=UTF-8",
             "Content-Type": "application/json; v=3; charset=UTF-8"
           ],
           @config ->
          %Vimond.Response{
            status_code: 200,
            body: Jason.encode!(%{products: []}),
            headers: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
          }
        end
      )

      assert products(1083, @config) == {:ok, %{products: []}}
    end

    test "with error from Vimond" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "productgroup/1235/products",
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8"
                         ],
                         @config ->
        %Vimond.Response{status_code: 500}
      end)

      assert capture_log(fn ->
               assert products("1235", @config) == {:error, "Failed to fetch products"}
             end) =~ "handle_products_response: Unexpected response"
    end
  end
end
