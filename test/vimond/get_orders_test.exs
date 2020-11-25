defmodule Vimond.Client.GetOrdersTest do
  use ExUnit.Case, async: true
  alias Vimond.Config
  import Vimond.Client
  import Hammox

  setup :verify_on_exit!

  @config %Config{
    base_url: "https://vimond-rest-api.example.com/api/platform/",
    api_key: "key",
    api_secret: "apisecret"
  }

  describe "current orders user authenticated" do
    test "with valid credentials" do
      Vimond.HTTPClientMock
      |> expect(:get, fn
        "user/123/orders/current",
        [
          Accept: "application/json; v=3; charset=UTF-8",
          "Content-Type": "application/json; v=3; charset=UTF-8",
          Authorization: "Bearer valid_vimond_token",
          Cookie: "rememberMe=valid_remember_me"
        ],
        @config ->
          body =
            [
              %{
                "accessEndDate" => "2019-03-27T20:47:56Z",
                "autorenewErrors" => 0,
                "autorenewStatus" => "ACTIVE",
                "currency" => "SEK",
                "earliestEndDate" => "2019-03-13T08:47:56Z",
                "endDate" => "2019-03-27T08:47:56Z",
                "externalOrderRef" => "565276867",
                "id" => 100_366_001,
                "initPrice" => 0.0,
                "ip" => "54.170.219.1",
                "orderRef" => "100247000",
                "paymentInfo" => "4571 10** **** 0000",
                "paymentInfoExpiryDate" => "2022-01-01T00:00:00Z",
                "paymentProviderId" => 33,
                "period" => "PT2592000S",
                "platformId" => 27,
                "price" => 139.0,
                "productGroupId" => 1235,
                "productGroupUri" => %{"uri" => "/api/cse/productgroup/1235"},
                "productId" => 1491,
                "productName" => "C More TV4 Månad",
                "productPaymentId" => 5540,
                "productPaymentUri" => %{
                  "uri" => "/api/cse/productgroup/1235/products/1491/productPayments/5540"
                },
                "productUri" => %{"uri" => "/api/cse/productgroup/1235/products/1491"},
                "referrer" => "Com Hem",
                "registered" => "2019-03-13T08:47:56Z",
                "startDate" => "2019-03-13T08:47:56Z",
                "status" => "ACTIVE",
                "statusText" => "Purchase sucessfull",
                "uri" => "/api/cse/order/100366001",
                "userId" => 123,
                "userPaymentMethod" => %{
                  "allowOneClickBuy" => true,
                  "expirationDate" => "2022-01-01T00:00:00Z",
                  "expireDate" => "2022-01-01T00:00:00Z",
                  "extAgreementRef" => "565276867",
                  "id" => "0b166356-e717-4efc-80ab-2ad3f71ef6d0",
                  "paymentInfo" => "4571 10** **** 0000",
                  "paymentProviderId" => 33,
                  "registered" => "2019-03-13T08:48:37Z",
                  "userId" => 123,
                  "userPaymentMethodStatus" => "ACTIVE",
                  "userPaymentMethodType" => "CREDIT_CARD"
                }
              }
            ]
            |> Jason.encode!()

          %Vimond.Response{
            status_code: 200,
            body: body,
            headers: %{"content-type" => "application/json;v=3;charset=UTF-8"}
          }
      end)

      assert current_orders("123", "valid_vimond_token", "valid_remember_me", @config) == {
               :ok,
               %{
                 orders: [
                   %Vimond.Order{
                     asset_id: nil,
                     end_date: ~U[2019-03-27 08:47:56Z],
                     order_id: 100_366_001,
                     product_group_id: 1235,
                     product_id: 1491,
                     product_payment_id: 5540,
                     referrer: "Com Hem"
                   }
                 ]
               }
             }
    end

    test "with valid credentials and multiple orders" do
      Vimond.HTTPClientMock
      |> expect(:get, fn
        "user/123/orders/current",
        [
          Accept: "application/json; v=3; charset=UTF-8",
          "Content-Type": "application/json; v=3; charset=UTF-8",
          Authorization: "Bearer valid_vimond_authorization_token",
          Cookie: "rememberMe=valid_remember_me"
        ],
        @config ->
          body =
            [
              %{
                "accessEndDate" => "2019-03-27T20:47:56Z",
                "autorenewErrors" => 0,
                "autorenewStatus" => "ACTIVE",
                "currency" => "SEK",
                "earliestEndDate" => "2019-03-13T08:47:56Z",
                "endDate" => "2019-03-27T08:47:56Z",
                "externalOrderRef" => "565276867",
                "id" => 100_366_001,
                "initPrice" => 0.0,
                "ip" => "54.170.219.1",
                "orderRef" => "100247000",
                "paymentInfo" => "4571 10** **** 0000",
                "paymentInfoExpiryDate" => "2022-01-01T00:00:00Z",
                "paymentProviderId" => 33,
                "period" => "PT2592000S",
                "platformId" => 27,
                "price" => 139.0,
                "productGroupId" => 1235,
                "productGroupUri" => %{"uri" => "/api/cse/productgroup/1235"},
                "productId" => 1491,
                "productName" => "C More TV4 Månad",
                "productPaymentId" => 5540,
                "productPaymentUri" => %{
                  "uri" => "/api/cse/productgroup/1235/products/1491/productPayments/5540"
                },
                "productUri" => %{"uri" => "/api/cse/productgroup/1235/products/1491"},
                "registered" => "2019-03-13T08:47:56Z",
                "startDate" => "2019-03-13T08:47:56Z",
                "status" => "ACTIVE",
                "statusText" => "Purchase sucessfull",
                "uri" => "/api/cse/order/100366001",
                "userId" => 123,
                "userPaymentMethod" => %{
                  "allowOneClickBuy" => true,
                  "expirationDate" => "2022-01-01T00:00:00Z",
                  "expireDate" => "2022-01-01T00:00:00Z",
                  "extAgreementRef" => "565276867",
                  "id" => "0b166356-e717-4efc-80ab-2ad3f71ef6d0",
                  "paymentInfo" => "4571 10** **** 0000",
                  "paymentProviderId" => 33,
                  "registered" => "2019-03-13T08:48:37Z",
                  "userId" => 123,
                  "userPaymentMethodStatus" => "ACTIVE",
                  "userPaymentMethodType" => "CREDIT_CARD"
                }
              },
              %{
                "accessEndDate" => "2019-03-27T20:47:56Z",
                "autorenewErrors" => 0,
                "autorenewStatus" => "ACTIVE",
                "currency" => "SEK",
                "earliestEndDate" => "2019-03-13T08:47:56Z",
                "endDate" => "2019-03-27T08:47:56Z",
                "externalOrderRef" => "565276867",
                "id" => 100_366_002,
                "initPrice" => 0.0,
                "ip" => "54.170.219.1",
                "orderRef" => "100247000",
                "paymentInfo" => "4571 10** **** 0000",
                "paymentInfoExpiryDate" => "2022-01-01T00:00:00Z",
                "paymentProviderId" => 33,
                "period" => "PT2592000S",
                "platformId" => 27,
                "price" => 139.0,
                "productGroupId" => 1235,
                "productGroupUri" => %{"uri" => "/api/cse/productgroup/1235"},
                "productId" => 1491,
                "productName" => "C More TV4 Månad",
                "productPaymentId" => 5540,
                "productPaymentUri" => %{
                  "uri" => "/api/cse/productgroup/1235/products/1491/productPayments/5540"
                },
                "productUri" => %{"uri" => "/api/cse/productgroup/1235/products/1491"},
                "registered" => "2019-03-13T08:47:56Z",
                "startDate" => "2019-03-13T08:47:56Z",
                "status" => "ACTIVE",
                "statusText" => "Purchase sucessfull",
                "uri" => "/api/cse/order/100366001",
                "userId" => 123,
                "userPaymentMethod" => %{
                  "allowOneClickBuy" => true,
                  "expirationDate" => "2022-01-01T00:00:00Z",
                  "expireDate" => "2022-01-01T00:00:00Z",
                  "extAgreementRef" => "565276867",
                  "id" => "0b166356-e717-4efc-80ab-2ad3f71ef6d0",
                  "paymentInfo" => "4571 10** **** 0000",
                  "paymentProviderId" => 33,
                  "registered" => "2019-03-13T08:48:37Z",
                  "userId" => 123,
                  "userPaymentMethodStatus" => "ACTIVE",
                  "userPaymentMethodType" => "CREDIT_CARD"
                }
              }
            ]
            |> Jason.encode!()

          %Vimond.Response{
            status_code: 200,
            body: body,
            headers: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
          }
      end)

      current_orders = current_orders("123", "valid_vimond_authorization_token", "valid_remember_me", @config)

      assert current_orders ==
               {:ok,
                %{
                  orders: [
                    %Vimond.Order{
                      order_id: 100_366_001,
                      end_date: ~U[2019-03-27 08:47:56Z],
                      product_group_id: 1235,
                      product_id: 1491,
                      product_payment_id: 5540
                    },
                    %Vimond.Order{
                      order_id: 100_366_002,
                      end_date: ~U[2019-03-27 08:47:56Z],
                      product_group_id: 1235,
                      product_id: 1491,
                      product_payment_id: 5540
                    }
                  ]
                }}
    end

    test "with invalid credentials" do
      Vimond.HTTPClientMock
      |> expect(:get, fn
        _path, _headers, _config ->
          body =
            %{
              "error" => %{
                "code" => "UNAUTHORIZED",
                "description" => "Not authorized",
                "id" => "1049",
                "reference" => "da9fe49eb21e24a3",
                "status" => 401
              }
            }
            |> Jason.encode!()

          %Vimond.Response{
            status_code: 401,
            body: body,
            headers: %{"content-type" => "application/json;v=\"2\";charset=UTF-8"}
          }
      end)

      assert current_orders("123", "invalid_vimond_authorization_token", "invalid_remember_me", @config) ==
               {:error, %{type: :invalid_credentials, source_errors: ["Not authorized"]}}
    end

    test "with an unknown response" do
      Vimond.HTTPClientMock
      |> expect(:get, fn
        _path, _headers, _config ->
          body =
            %{
              "error" => %{
                "code" => "SHIT_HIT_THE_FAN",
                "description" => "Not authorized",
                "id" => "1049",
                "reference" => "da9fe49eb21e24a3",
                "status" => 400
              }
            }
            |> Jason.encode!()

          %Vimond.Response{
            status_code: 400,
            body: body,
            headers: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
          }
      end)

      assert current_orders("123", "valid_vimond_authorization_token", "valid_remember_me", @config) ==
               {:error, %{type: :generic, source_errors: ["Unexpected error"]}}
    end
  end

  describe "current orders app authenticated" do
    test "with valid credentials" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn
        "user/123/orders/current",
        [Accept: "application/json; v=3; charset=UTF-8", "Content-Type": "application/json; v=3; charset=UTF-8"],
        @config ->
          body =
            [
              %{
                "accessEndDate" => "2019-03-27T20:47:56Z",
                "autorenewErrors" => 0,
                "autorenewStatus" => "ACTIVE",
                "currency" => "SEK",
                "earliestEndDate" => "2019-03-13T08:47:56Z",
                "endDate" => "2019-03-27T08:47:56Z",
                "externalOrderRef" => "565276867",
                "id" => 100_366_001,
                "initPrice" => 0.0,
                "ip" => "54.170.219.1",
                "orderRef" => "100247000",
                "paymentInfo" => "4571 10** **** 0000",
                "paymentInfoExpiryDate" => "2022-01-01T00:00:00Z",
                "paymentProviderId" => 33,
                "period" => "PT2592000S",
                "platformId" => 27,
                "price" => 139.0,
                "productGroupId" => 1235,
                "productGroupUri" => %{"uri" => "/api/cse/productgroup/1235"},
                "productId" => 1491,
                "productName" => "C More TV4 Månad",
                "productPaymentId" => 5540,
                "productPaymentUri" => %{
                  "uri" => "/api/cse/productgroup/1235/products/1491/productPayments/5540"
                },
                "productUri" => %{"uri" => "/api/cse/productgroup/1235/products/1491"},
                "referrer" => "Com Hem",
                "registered" => "2019-03-13T08:47:56Z",
                "startDate" => "2019-03-13T08:47:56Z",
                "status" => "ACTIVE",
                "statusText" => "Purchase sucessfull",
                "uri" => "/api/cse/order/100366001",
                "userId" => 123,
                "userPaymentMethod" => %{
                  "allowOneClickBuy" => true,
                  "expirationDate" => "2022-01-01T00:00:00Z",
                  "expireDate" => "2022-01-01T00:00:00Z",
                  "extAgreementRef" => "565276867",
                  "id" => "0b166356-e717-4efc-80ab-2ad3f71ef6d0",
                  "paymentInfo" => "4571 10** **** 0000",
                  "paymentProviderId" => 33,
                  "registered" => "2019-03-13T08:48:37Z",
                  "userId" => 123,
                  "userPaymentMethodStatus" => "ACTIVE",
                  "userPaymentMethodType" => "CREDIT_CARD"
                }
              }
            ]
            |> Jason.encode!()

          %Vimond.Response{
            status_code: 200,
            body: body,
            headers: %{"content-type" => "application/json;v=3;charset=UTF-8"}
          }
      end)

      assert current_orders_signed("123", @config) == {
               :ok,
               %{
                 orders: [
                   %Vimond.Order{
                     referrer: "Com Hem",
                     end_date: ~U[2019-03-27 08:47:56Z],
                     order_id: 100_366_001,
                     product_group_id: 1235,
                     product_id: 1491,
                     product_payment_id: 5540
                   }
                 ]
               }
             }
    end
  end

  describe "all orders app authenticated" do
    test "with valid credentials" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn
        "user/123/orders",
        [Accept: "application/json; v=3; charset=UTF-8", "Content-Type": "application/json; v=3; charset=UTF-8"],
        @config ->
          body =
            %{
              "active" => [
                %{
                  "accessEndDate" => "2019-03-27T20:47:56Z",
                  "autorenewErrors" => 0,
                  "autorenewStatus" => "ACTIVE",
                  "currency" => "SEK",
                  "earliestEndDate" => "2019-03-13T08:47:56Z",
                  "endDate" => "2019-03-27T08:47:56Z",
                  "externalOrderRef" => "565276867",
                  "id" => 100_366_001,
                  "initPrice" => 0.0,
                  "ip" => "54.170.219.1",
                  "orderRef" => "100247000",
                  "paymentInfo" => "4571 10** **** 0000",
                  "paymentInfoExpiryDate" => "2022-01-01T00:00:00Z",
                  "paymentProviderId" => 33,
                  "period" => "PT2592000S",
                  "platformId" => 27,
                  "price" => 139.0,
                  "productGroupId" => 1235,
                  "productGroupUri" => %{"uri" => "/api/cse/productgroup/1235"},
                  "productId" => 1491,
                  "productName" => "C More TV4 Månad",
                  "productPaymentId" => 5540,
                  "productPaymentUri" => %{
                    "uri" => "/api/cse/productgroup/1235/products/1491/productPayments/5540"
                  },
                  "productUri" => %{"uri" => "/api/cse/productgroup/1235/products/1491"},
                  "referrer" => "Com Hem",
                  "registered" => "2019-03-13T08:47:56Z",
                  "startDate" => "2019-03-13T08:47:56Z",
                  "status" => "ACTIVE",
                  "statusText" => "Purchase sucessfull",
                  "uri" => "/api/cse/order/100366001",
                  "userId" => 123,
                  "userPaymentMethod" => %{
                    "allowOneClickBuy" => true,
                    "expirationDate" => "2022-01-01T00:00:00Z",
                    "expireDate" => "2022-01-01T00:00:00Z",
                    "extAgreementRef" => "565276867",
                    "id" => "0b166356-e717-4efc-80ab-2ad3f71ef6d0",
                    "paymentInfo" => "4571 10** **** 0000",
                    "paymentProviderId" => 33,
                    "registered" => "2019-03-13T08:48:37Z",
                    "userId" => 123,
                    "userPaymentMethodStatus" => "ACTIVE",
                    "userPaymentMethodType" => "CREDIT_CARD"
                  }
                },
                %{
                  "accessEndDate" => "2019-03-27T20:47:56Z",
                  "autorenewErrors" => 0,
                  "autorenewStatus" => "ACTIVE",
                  "currency" => "SEK",
                  "earliestEndDate" => "2019-03-13T08:47:56Z",
                  "endDate" => "2019-03-27T08:47:56Z",
                  "externalOrderRef" => "565276867",
                  "id" => 100_366_002,
                  "initPrice" => 0.0,
                  "ip" => "54.170.219.1",
                  "orderRef" => "100247000",
                  "paymentInfo" => "4571 10** **** 0000",
                  "paymentInfoExpiryDate" => "2022-01-01T00:00:00Z",
                  "paymentProviderId" => 33,
                  "period" => "PT2592000S",
                  "platformId" => 27,
                  "price" => 139.0,
                  "productGroupId" => 1235,
                  "productGroupUri" => %{"uri" => "/api/cse/productgroup/1235"},
                  "productId" => 1491,
                  "productName" => "C More TV4 Månad",
                  "productPaymentId" => 5540,
                  "productPaymentUri" => %{
                    "uri" => "/api/cse/productgroup/1235/products/1491/productPayments/5540"
                  },
                  "productUri" => %{"uri" => "/api/cse/productgroup/1235/products/1491"},
                  "registered" => "2019-03-13T08:47:56Z",
                  "startDate" => "2019-03-13T08:47:56Z",
                  "status" => "ACTIVE",
                  "statusText" => "Purchase sucessfull",
                  "uri" => "/api/cse/order/100366001",
                  "userId" => 123,
                  "userPaymentMethod" => %{
                    "allowOneClickBuy" => true,
                    "expirationDate" => "2022-01-01T00:00:00Z",
                    "expireDate" => "2022-01-01T00:00:00Z",
                    "extAgreementRef" => "565276867",
                    "id" => "0b166356-e717-4efc-80ab-2ad3f71ef6d0",
                    "paymentInfo" => "4571 10** **** 0000",
                    "paymentProviderId" => 33,
                    "registered" => "2019-03-13T08:48:37Z",
                    "userId" => 123,
                    "userPaymentMethodStatus" => "ACTIVE",
                    "userPaymentMethodType" => "CREDIT_CARD"
                  }
                }
              ],
              "future" => []
            }
            |> Jason.encode!()

          %Vimond.Response{
            status_code: 200,
            body: body,
            headers: %{"content-type" => "application/json;v=3;charset=UTF-8"}
          }
      end)
      |> expect(:get_signed, fn
        "user/123/orders/history",
        [Accept: "application/json; v=3; charset=UTF-8", "Content-Type": "application/json; v=3; charset=UTF-8"],
        @config ->
          body =
            [
              %{
                "accessEndDate" => "2020-12-02T09:50:50Z",
                "autorenewStatus" => "NOT_ELIGIBLE",
                "earliestEndDate" => "2020-11-25T09:50:50Z",
                "endDate" => "2020-12-02T09:50:50Z",
                "id" => 100_366_003,
                "initPrice" => 249.0,
                "initPriceAndPeriodBypassed" => false,
                "ip" => "54.74.214.67",
                "period" => "PT604800S",
                "platformId" => 27,
                "price" => 249.0,
                "productGroupId" => 1017,
                "productGroupUri" => %{"uri" => "/api/cse/productgroup/1017"},
                "productId" => 1028,
                "productName" => "Matchbiljett 249 kr Ett program",
                "productPaymentId" => 2811,
                "productPaymentUri" => %{
                  "uri" => "/api/cse/productgroup/1017/products/1028/productPayments/2811"
                },
                "productUri" => %{"uri" => "/api/cse/productgroup/1017/products/1028"},
                "progId" => 13_292_464,
                "referrer" => "Purchase Bravo",
                "registered" => "2020-11-25T09:50:50Z",
                "startDate" => "2020-11-25T09:50:50Z",
                "status" => "ACTIVE",
                "statusText" => "Order created.",
                "uri" => "/api/cse/order/205745879",
                "userId" => 102_806_996,
                "userPaymentMethod" => %{}
              }
            ]
            |> Jason.encode!()

          %Vimond.Response{
            status_code: 200,
            body: body,
            headers: %{"content-type" => "application/json;v=3;charset=UTF-8"}
          }
      end)

      assert all_orders_signed("123", @config) == {
               :ok,
               %{
                 orders: [
                   %Vimond.Order{
                     end_date: ~U[2019-03-27 08:47:56Z],
                     order_id: 100_366_001,
                     product_group_id: 1235,
                     product_id: 1491,
                     product_payment_id: 5540,
                     referrer: "Com Hem"
                   },
                   %Vimond.Order{
                     order_id: 100_366_002,
                     end_date: ~U[2019-03-27 08:47:56Z],
                     product_group_id: 1235,
                     product_id: 1491,
                     product_payment_id: 5540
                   },
                   %Vimond.Order{
                     asset_id: 13_292_464,
                     order_id: 100_366_003,
                     end_date: ~U[2020-12-02 09:50:50Z],
                     product_group_id: 1017,
                     product_id: 1028,
                     product_payment_id: 2811,
                     referrer: "Purchase Bravo"
                   }
                 ]
               }
             }
    end
  end
end
