defmodule Vimond.Client.CurrentOrdersTest do
  use ExUnit.Case, async: true
  alias Vimond.Config
  import Vimond.Client
  import Mox

  setup :verify_on_exit!

  @config %Config{
    base_url: "https://vimond-rest-api.example.com/api/platform/",
    api_key: "key",
    api_secret: "apisecret"
  }

  describe "user authenticated" do
    test "with valid credentials" do
      HTTPClientMock
      |> expect(
        :get,
        fn "https://vimond-rest-api.example.com/api/platform/user/123/orders/current",
           Accept: "application/json; v=3; charset=UTF-8",
           "Content-Type": "application/json; v=3; charset=UTF-8",
           Authorization: "Bearer valid_vimond_token",
           Cookie: "rememberMe=valid_remember_me" ->
          body =
            [
              %{
                "progId" => nil,
                "callbackUrl" => nil,
                "productGroupId" => 1083,
                "productId" => 1400,
                "assetName" => nil,
                "userPaymentMethod" => %{
                  "userPaymentMethodStatus" => "ACTIVE",
                  "redirectUrl" => nil,
                  "userPaymentMethodType" => "CREDIT_CARD",
                  "captureAttemptLog" => nil,
                  "callbackUrl" => nil,
                  "expireDate" => 1_590_976_800_000,
                  "allowOneClickBuy" => true,
                  "userId" => 28_059_191,
                  "paymentProviderId" => 27,
                  "expirationDate" => 1_590_976_800_000,
                  "extAgreementRef" => "397319623",
                  "paymentInfo" => "**** **** **** 9474",
                  "registered" => 1_469_800_270_000,
                  "id" => "35d6df66-60a9-4e90-9b29-f97fdf032766",
                  "uri" => nil
                },
                "startDate" => 1_470_677_406_000,
                "userId" => 28_059_191,
                "productPaymentId" => 2624,
                "upgradeOrderId" => 40_102_027,
                "paymentInfoExpiryDate" => 1_590_976_800_000,
                "upgradeOption" => nil,
                "originalPrice" => nil,
                "discount" => nil,
                "deviceInfo" => %{
                  "present" => false
                },
                "price" => 99,
                "paymentProviderId" => 27,
                "referrer" => "Com Hem TVE",
                "endDate" => 1_504_805_400_000,
                "notifyUserOnCreation" => nil,
                "productName" => "Film och Serier SE Månad",
                "earliestEndDate" => 1_504_805_400_000,
                "voucherCode" => nil,
                "extUserId" => nil,
                "ip" => "10.54.69.53",
                "orderRef" => nil,
                "initPrice" => nil,
                "paymentInfo" => "**** **** **** 9474",
                "autoRenewStopDate" => 1_609_418_700_000,
                "extendedTime" => nil,
                "categoryId" => nil,
                "platformId" => 7,
                "paymentObject" => nil,
                "productGroupUri" => %{
                  "uri" => "/api/web/productgroup/1083"
                },
                "accessEndDate" => 1_504_809_000_000,
                "isp" => "TV4",
                "period" => 2_592_000,
                "autorenewStatus" => "ACTIVE",
                "currency" => "SEK",
                "appName" => nil,
                "status" => "ACTIVE",
                "id" => 40_102_071,
                "uri" => "/api/web/user/28059191/orders/40102071"
              }
            ]
            |> Jason.encode!()

          %HTTPotion.Response{
            status_code: 200,
            body: body,
            headers: %HTTPotion.Headers{
              hdrs: %{"content-type" => "application/json;v=3;charset=UTF-8"}
            }
          }
        end
      )

      expected = {
        :ok,
        %{
          orders: [
            %Vimond.Order{
              order_id: 40_102_071,
              product_id: 1400,
              product_group_id: 1083,
              asset_id: nil,
              referrer: "Com Hem TVE",
              product_payment_id: 2624
            }
          ]
        }
      }

      assert current_orders("123", "valid_vimond_token", "valid_remember_me", @config) == expected
    end

    test "with valid credentials and multiple orders" do
      HTTPClientMock
      |> expect(
        :get,
        fn "https://vimond-rest-api.example.com/api/platform/user/123/orders/current",
           Accept: "application/json; v=3; charset=UTF-8",
           "Content-Type": "application/json; v=3; charset=UTF-8",
           Authorization: "Bearer valid_vimond_authorization_token",
           Cookie: "rememberMe=valid_remember_me" ->
          body =
            [
              %{
                "progId" => nil,
                "callbackUrl" => nil,
                "productGroupId" => 1083,
                "productId" => 1400,
                "assetName" => nil,
                "userPaymentMethod" => %{
                  "userPaymentMethodStatus" => "ACTIVE",
                  "redirectUrl" => nil,
                  "userPaymentMethodType" => "CREDIT_CARD",
                  "captureAttemptLog" => nil,
                  "callbackUrl" => nil,
                  "expireDate" => 1_590_976_800_000,
                  "allowOneClickBuy" => true,
                  "userId" => 28_059_191,
                  "paymentProviderId" => 27,
                  "expirationDate" => 1_590_976_800_000,
                  "extAgreementRef" => "397319623",
                  "paymentInfo" => "**** **** **** 9474",
                  "registered" => 1_469_800_270_000,
                  "id" => "35d6df66-60a9-4e90-9b29-f97fdf032766",
                  "uri" => nil
                },
                "startDate" => 1_470_677_406_000,
                "userId" => 28_059_191,
                "productPaymentId" => 2624,
                "upgradeOrderId" => 40_102_027,
                "paymentInfoExpiryDate" => 1_590_976_800_000,
                "upgradeOption" => nil,
                "originalPrice" => nil,
                "discount" => nil,
                "deviceInfo" => %{
                  "present" => false
                },
                "price" => 99,
                "paymentProviderId" => 27,
                "referrer" => nil,
                "endDate" => 1_504_805_400_000,
                "notifyUserOnCreation" => nil,
                "productName" => "Film och Serier SE Månad",
                "earliestEndDate" => 1_504_805_400_000,
                "voucherCode" => nil,
                "extUserId" => nil,
                "ip" => "10.54.69.53",
                "orderRef" => nil,
                "initPrice" => nil,
                "paymentInfo" => "**** **** **** 9474",
                "autoRenewStopDate" => 1_609_418_700_000,
                "extendedTime" => nil,
                "categoryId" => nil,
                "platformId" => 7,
                "paymentObject" => nil,
                "productGroupUri" => %{
                  "uri" => "/api/web/productgroup/1083"
                },
                "accessEndDate" => 1_504_809_000_000,
                "isp" => "TV4",
                "period" => 2_592_000,
                "autorenewStatus" => "ACTIVE",
                "currency" => "SEK",
                "appName" => nil,
                "status" => "ACTIVE",
                "id" => 40_102_071,
                "uri" => "/api/web/user/28059191/orders/40102071"
              },
              %{
                "progId" => nil,
                "callbackUrl" => nil,
                "productGroupId" => 1083,
                "productId" => 1400,
                "assetName" => nil,
                "userPaymentMethod" => %{
                  "userPaymentMethodStatus" => "ACTIVE",
                  "redirectUrl" => nil,
                  "userPaymentMethodType" => "CREDIT_CARD",
                  "captureAttemptLog" => nil,
                  "callbackUrl" => nil,
                  "expireDate" => 1_590_976_800_000,
                  "allowOneClickBuy" => true,
                  "userId" => 28_059_191,
                  "paymentProviderId" => 27,
                  "expirationDate" => 1_590_976_800_000,
                  "extAgreementRef" => "397319623",
                  "paymentInfo" => "**** **** **** 9474",
                  "registered" => 1_469_800_270_000,
                  "id" => "35d6df66-60a9-4e90-9b29-f97fdf032766",
                  "uri" => nil
                },
                "startDate" => 1_470_677_406_000,
                "userId" => 28_059_191,
                "productPaymentId" => 2624,
                "upgradeOrderId" => 40_102_027,
                "paymentInfoExpiryDate" => 1_590_976_800_000,
                "upgradeOption" => nil,
                "originalPrice" => nil,
                "discount" => nil,
                "deviceInfo" => %{
                  "present" => false
                },
                "price" => 99,
                "paymentProviderId" => 27,
                "referrer" => nil,
                "endDate" => 1_504_805_400_000,
                "notifyUserOnCreation" => nil,
                "productName" => "Film och Serier SE År",
                "earliestEndDate" => 1_504_805_400_000,
                "voucherCode" => nil,
                "extUserId" => nil,
                "ip" => "10.54.69.53",
                "orderRef" => nil,
                "initPrice" => nil,
                "paymentInfo" => "**** **** **** 9474",
                "autoRenewStopDate" => nil,
                "extendedTime" => nil,
                "categoryId" => nil,
                "platformId" => 7,
                "paymentObject" => nil,
                "productGroupUri" => %{
                  "uri" => "/api/web/productgroup/1083"
                },
                "accessEndDate" => 1_504_809_000_000,
                "isp" => "TV4",
                "period" => 2_592_000,
                "autorenewStatus" => "STOPPED",
                "currency" => "SEK",
                "appName" => nil,
                "status" => "ACTIVE",
                "id" => 40_102_072,
                "uri" => "/api/web/user/28059191/orders/40102071"
              }
            ]
            |> Jason.encode!()

          %HTTPotion.Response{
            status_code: 200,
            body: body,
            headers: %HTTPotion.Headers{
              hdrs: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
            }
          }
        end
      )

      expected = {
        :ok,
        %{
          orders: [
            %Vimond.Order{
              order_id: 40_102_071,
              product_id: 1400,
              product_group_id: 1083,
              asset_id: nil,
              referrer: nil,
              product_payment_id: 2624
            },
            %Vimond.Order{
              order_id: 40_102_072,
              product_id: 1400,
              product_group_id: 1083,
              asset_id: nil,
              referrer: nil,
              product_payment_id: 2624
            }
          ]
        }
      }

      assert current_orders(
               "123",
               "valid_vimond_authorization_token",
               "valid_remember_me",
               @config
             ) == expected
    end

    test "with invalid credentials" do
      HTTPClientMock
      |> expect(:get, fn _, _ ->
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

        %HTTPotion.Response{
          status_code: 401,
          body: body,
          headers: %HTTPotion.Headers{
            hdrs: %{"content-type" => "application/json;v=\"2\";charset=UTF-8"}
          }
        }
      end)

      expected = {:error, %{type: :invalid_credentials, source_errors: ["Not authorized"]}}

      assert current_orders(
               "123",
               "invalid_vimond_authorization_token",
               "invalid_remember_me",
               @config
             ) == expected
    end

    test "with an unknown response" do
      HTTPClientMock
      |> expect(:get, fn _, _ ->
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

        %HTTPotion.Response{
          status_code: 400,
          body: body,
          headers: %HTTPotion.Headers{
            hdrs: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
          }
        }
      end)

      expected = {:error, %{type: :generic, source_errors: ["Unexpected error"]}}

      assert current_orders(
               "123",
               "valid_vimond_authorization_token",
               "valid_remember_me",
               @config
             ) == expected
    end
  end

  describe "app authenticated" do
    test "with valid credentials" do
      HTTPClientMock
      |> expect(
        :get,
        fn "https://vimond-rest-api.example.com/api/platform/user/123/orders/current",
           Accept: "application/json; v=3; charset=UTF-8",
           "Content-Type": "application/json; v=3; charset=UTF-8",
           Authorization: "SUMO " <> _,
           Date: "Wed, 02 Sep 2015 13:24:35 +0000" ->
          body =
            [
              %{
                "progId" => nil,
                "callbackUrl" => nil,
                "productGroupId" => 1083,
                "productId" => 1400,
                "assetName" => nil,
                "userPaymentMethod" => %{
                  "userPaymentMethodStatus" => "ACTIVE",
                  "redirectUrl" => nil,
                  "userPaymentMethodType" => "CREDIT_CARD",
                  "captureAttemptLog" => nil,
                  "callbackUrl" => nil,
                  "expireDate" => 1_590_976_800_000,
                  "allowOneClickBuy" => true,
                  "userId" => 28_059_191,
                  "paymentProviderId" => 27,
                  "expirationDate" => 1_590_976_800_000,
                  "extAgreementRef" => "397319623",
                  "paymentInfo" => "**** **** **** 9474",
                  "registered" => 1_469_800_270_000,
                  "id" => "35d6df66-60a9-4e90-9b29-f97fdf032766",
                  "uri" => nil
                },
                "startDate" => 1_470_677_406_000,
                "userId" => 28_059_191,
                "productPaymentId" => 2624,
                "upgradeOrderId" => 40_102_027,
                "paymentInfoExpiryDate" => 1_590_976_800_000,
                "upgradeOption" => nil,
                "originalPrice" => nil,
                "discount" => nil,
                "deviceInfo" => %{
                  "present" => false
                },
                "price" => 99,
                "paymentProviderId" => 27,
                "referrer" => "Com Hem",
                "endDate" => 1_504_805_400_000,
                "notifyUserOnCreation" => nil,
                "productName" => "Film och Serier SE Månad",
                "earliestEndDate" => 1_504_805_400_000,
                "voucherCode" => nil,
                "extUserId" => nil,
                "ip" => "10.54.69.53",
                "orderRef" => nil,
                "initPrice" => nil,
                "paymentInfo" => "**** **** **** 9474",
                "autoRenewStopDate" => 1_609_418_700_000,
                "extendedTime" => nil,
                "categoryId" => nil,
                "platformId" => 7,
                "paymentObject" => nil,
                "productGroupUri" => %{
                  "uri" => "/api/web/productgroup/1083"
                },
                "accessEndDate" => 1_504_809_000_000,
                "isp" => "TV4",
                "period" => 2_592_000,
                "autorenewStatus" => "ACTIVE",
                "currency" => "SEK",
                "appName" => nil,
                "status" => "ACTIVE",
                "id" => 40_102_071,
                "uri" => "/api/web/user/28059191/orders/40102071"
              }
            ]
            |> Jason.encode!()

          %HTTPotion.Response{
            status_code: 200,
            body: body,
            headers: %HTTPotion.Headers{
              hdrs: %{"content-type" => "application/json;v=3;charset=UTF-8"}
            }
          }
        end
      )

      expected = {
        :ok,
        %{
          orders: [
            %Vimond.Order{
              order_id: 40_102_071,
              product_id: 1400,
              product_group_id: 1083,
              asset_id: nil,
              referrer: "Com Hem",
              product_payment_id: 2624
            }
          ]
        }
      }

      assert current_orders_signed("123", @config) == expected
    end
  end
end
