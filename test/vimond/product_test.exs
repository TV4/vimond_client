defmodule Vimond.Client.ProductTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  import Hammox
  import ExUnit.CaptureLog

  setup :verify_on_exit!

  @config %Vimond.Config{base_url: "https://vimond-rest-api.example.com/api/platform/"}

  describe "product with product group id and product id " do
    test "with full product" do
      Vimond.HTTPClientMock
      |> expect(
        :get,
        fn "productgroup/1235/products/1491",
           [
             Accept: "application/json; v=3; charset=UTF-8",
             "Content-Type": "application/json; v=3; charset=UTF-8"
           ],
           @config ->
          %Vimond.Response{
            status_code: 200,
            body:
              Jason.encode!(%{
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
              }),
            headers: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
          }
        end
      )

      assert product("1235", "1491", @config) ==
               {:ok,
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
                }}
    end

    test "with product with missing data" do
      Vimond.HTTPClientMock
      |> expect(
        :get,
        fn "productgroup/1083/products/1400",
           [
             Accept: "application/json; v=3; charset=UTF-8",
             "Content-Type": "application/json; v=3; charset=UTF-8"
           ],
           @config ->
          %Vimond.Response{
            status_code: 200,
            body: Jason.encode!(%{}),
            headers: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
          }
        end
      )

      assert product(1083, 1400, @config) ==
               {:ok,
                %Vimond.Product{
                  id: nil,
                  description: nil,
                  currency: nil,
                  enabled: nil,
                  minimum_periods: nil,
                  payment_plan: %Vimond.PaymentPlan{name: nil, payment_type: nil, period: nil},
                  price: nil,
                  product_group_id: nil,
                  product_payments_uri: nil,
                  product_status: nil,
                  sort_index: nil,
                  product_payments: []
                }}
    end

    test "with error from Vimond" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "productgroup/1235/products/1491",
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8"
                         ],
                         @config ->
        %Vimond.Response{status_code: 500}
      end)

      assert capture_log(fn ->
               assert product("1235", "1491", @config) == {:error, "Failed to fetch product"}
             end) =~ "handle_product_response: Unexpected response"
    end
  end

  describe "product with product id " do
    test "defaults the product group to 0" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "productgroup/0/products/1491",
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8"
                         ],
                         @config ->
        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(%{}),
          headers: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
        }
      end)

      assert elem(product("1491", @config), 0) == :ok
    end
  end
end
