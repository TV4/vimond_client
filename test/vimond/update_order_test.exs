defmodule Vimond.Client.UpdateOrderTest do
  use ExUnit.Case
  import Mox
  import Vimond.Client
  alias Vimond.Order

  @config %Vimond.Config{base_url: "https://vimond-rest-api.example.com/api/platform/"}

  setup :verify_on_exit!

  test "with updated properties" do
    Vimond.HTTPClientMock
    |> expect(:get_signed, fn "order/100363001",
                              [
                                Accept: "application/json; v=3; charset=UTF-8",
                                "Content-Type": "application/json; v=3; charset=UTF-8"
                              ],
                              _config ->
      %HTTPotion.Response{
        body:
          %{
            "accessEndDate" => "2020-03-13T14:45:16Z",
            "autorenewStatus" => "NOT_ELIGIBLE",
            "earliestEndDate" => "2044-03-29T13:09:13Z",
            "endDate" => "2020-03-13T14:45:16Z",
            "id" => 100_363_001,
            "ip" => "193.14.163.194",
            "period" => "PT790560000S",
            "platformId" => 27,
            "price" => 0.0,
            "productGroupId" => 2020,
            "productGroupUri" => %{"uri" => "/api/cse/productgroup/2020"},
            "productId" => 2640,
            "productName" => "C More Operatör",
            "productPaymentId" => 5660,
            "productPaymentUri" => %{
              "uri" => "/api/cse/productgroup/2020/products/2640/productPayments/5660"
            },
            "productUri" => %{"uri" => "/api/cse/productgroup/2020/products/2640"},
            "referrer" => "cmore-in-app-purchase",
            "registered" => "2019-03-11T13:09:13Z",
            "startDate" => "2019-03-11T13:09:13Z",
            "status" => "ACTIVE",
            "statusText" => "Order created.",
            "uri" => "/api/cse/order/100363001",
            "userId" => 100_076_004,
            "userPaymentMethod" => %{}
          }
          |> Jason.encode!(),
        headers: %HTTPotion.Headers{
          hdrs: %{
            "content-type" => "application/json; v=3;charset=UTF-8"
          }
        },
        status_code: 200
      }
    end)
    |> expect(:put_signed, fn "order/100363001",
                              body,
                              [
                                Accept: "application/json; v=3; charset=UTF-8",
                                "Content-Type": "application/json; v=3; charset=UTF-8"
                              ],
                              _config ->
      assert Jason.decode!(body) == %{
               "accessEndDate" => "2044-03-18T13:37:56Z",
               "autorenewStatus" => "NOT_ELIGIBLE",
               "earliestEndDate" => "2044-03-29T13:09:13Z",
               "endDate" => "2044-03-18T13:37:56Z",
               "id" => 100_363_001,
               "ip" => "193.14.163.194",
               "period" => "PT790560000S",
               "platformId" => 27,
               "price" => 0.0,
               "productGroupId" => 2020,
               "productId" => 123,
               "productName" => "C More Operatör",
               "productPaymentId" => 5660,
               "referrer" => "cmore-in-app-purchase",
               "registered" => "2019-03-11T13:09:13Z",
               "startDate" => "2019-03-11T13:09:13Z",
               "status" => "ACTIVE",
               "statusText" => "Order created.",
               "uri" => "/api/cse/order/100363001",
               "userId" => 100_076_004
             }

      %HTTPotion.Response{
        body:
          %{
            "accessEndDate" => "2044-03-18T13:37:56Z",
            "autorenewStatus" => "NOT_ELIGIBLE",
            "earliestEndDate" => "2044-03-29T13:09:13Z",
            "endDate" => "2044-03-18T13:37:56Z",
            "id" => 100_363_001,
            "ip" => "193.14.163.194",
            "period" => "PT790560000S",
            "platformId" => 27,
            "price" => 0.0,
            "productGroupId" => 2020,
            "productGroupUri" => %{},
            "productId" => 123,
            "productName" => "C More Operatör",
            "productPaymentId" => 5660,
            "referrer" => "cmore-in-app-purchase",
            "registered" => "2019-03-11T13:09:13Z",
            "startDate" => "2019-03-11T13:09:13Z",
            "status" => "ACTIVE",
            "statusText" => "Order created.",
            "userId" => 100_076_004,
            "userPaymentMethod" => %{}
          }
          |> Jason.encode!(),
        headers: %HTTPotion.Headers{
          hdrs: %{
            "content-type" => "application/json; v=3;charset=UTF-8"
          }
        },
        status_code: 200
      }
    end)

    assert update_order_signed(
             %Order{order_id: 100_363_001, product_id: 123, end_date: 2_341_921_076},
             @config
           ) ==
             {:ok,
              %Order{
                order_id: 100_363_001,
                product_id: 123,
                product_group_id: 2020,
                product_payment_id: 5660,
                referrer: "cmore-in-app-purchase",
                end_date: 2_341_921_076
              }}
  end
end
