defmodule Vimond.Client.TerminateOrdersTest do
  use ExUnit.Case
  alias Vimond.Config
  import Vimond.Client
  import Mox

  setup :verify_on_exit!

  @config %Config{
    base_url: "https://vimond-rest-api.example.com/api/platform/",
    api_key: "key",
    api_secret: "secret"
  }

  test "terminate order succeeds" do
    HTTPClientMock
    |> expect(:get, fn "https://vimond-rest-api.example.com/api/platform/order/123",
                       Accept: "application/json; v=3; charset=UTF-8",
                       "Content-Type": "application/json; v=3; charset=UTF-8",
                       Authorization: "SUMO key:" <> _,
                       Date: "Wed, 02 Sep 2015 13:24:35 +0000" ->
      json = %{
        "extendedTime" => nil,
        "startDate" => 1_509_001_257_000,
        "originalPrice" => nil,
        "userId" => 65_473_025,
        "productGroupId" => 7,
        "isp" => "TV4",
        "extUserId" => nil,
        "period" => 2_592_000,
        "id" => 75_382_498,
        "upgradeOrderId" => nil,
        "initPrice" => nil,
        "accessEndDate" => 1_511_593_257_000,
        "platformId" => 7,
        "ip" => "193.14.163.194",
        "autorenewStatus" => "NOT_ELIGIBLE",
        "productName" => "TV4 Play Premium Månad",
        "referrer" => "telia TVE",
        "endDate" => 1_511_593_257_000,
        "paymentInfoExpiryDate" => nil,
        "currency" => nil,
        "orderRef" => nil,
        "price" => 99.0,
        "upgradeOption" => nil,
        "notifyUserOnCreation" => nil,
        "appName" => nil,
        "status" => "ACTIVE",
        "paymentObject" => nil,
        "discount" => nil,
        "voucherCode" => nil,
        "productPaymentId" => 2548,
        "productId" => 1314,
        "categoryId" => nil,
        "earliestEndDate" => 1_509_001_257_000,
        "autorenewErrors" => nil,
        "deviceInfo" => %{"present" => false},
        "userPaymentMethod" => %{
          "allowOneClickBuy" => nil,
          "callbackUrl" => nil,
          "captureAttemptLog" => nil,
          "expirationDate" => nil,
          "expireDate" => nil,
          "extAgreementRef" => nil,
          "id" => nil,
          "paymentInfo" => nil,
          "paymentProviderId" => nil,
          "redirectUrl" => nil,
          "registered" => nil,
          "uri" => nil,
          "userId" => nil,
          "userPaymentMethodStatus" => nil
        },
        "productGroupUri" => %{"uri" => nil},
        "callbackUrl" => nil,
        "paymentInfo" => nil,
        "progId" => nil,
        "paymentProviderId" => nil,
        "autoRenewStopDate" => nil,
        "assetName" => nil,
        "uri" => "/api/platform/user/65473025/orders/75382498"
      }

      %HTTPotion.Response{status_code: 200, body: Jason.encode!(json)}
    end)

    HTTPClientMock
    |> expect(:put, fn "https://vimond-rest-api.example.com/api/platform/order/123",
                       body,
                       Accept: "application/json; v=3; charset=UTF-8",
                       "Content-Type": "application/json; v=3; charset=UTF-8",
                       Authorization: "SUMO key:" <> _,
                       Date: "Wed, 02 Sep 2015 13:24:35 +0000" ->
      %{"accessEndDate" => 1_441_200_275_000, "endDate" => 1_441_200_275_000} =
        Jason.decode!(body)

      json = %{
        "startDate" => 1_509_001_257_000,
        "userId" => 65_473_025,
        "productGroupId" => 7,
        "isp" => "TV4",
        "extUserId" => nil,
        "period" => 2_592_000,
        "id" => 75_382_498,
        "accessEndDate" => 1_441_200_275_000,
        "platformId" => 7,
        "autorenewStatus" => "NOT_ELIGIBLE",
        "productName" => "TV4 Play Premium Månad",
        "referrer" => "telia TVE",
        "endDate" => 1_441_200_275_000,
        "price" => 99.0,
        "status" => "ACTIVE",
        "productPaymentId" => 2548,
        "productId" => 1314,
        "earliestEndDate" => 1_509_001_257_000,
        "deviceInfo" => %{"present" => false},
        "userPaymentMethod" => %{
          "allowOneClickBuy" => nil,
          "callbackUrl" => nil,
          "captureAttemptLog" => nil,
          "expirationDate" => nil,
          "expireDate" => nil,
          "extAgreementRef" => nil,
          "id" => nil,
          "paymentInfo" => nil,
          "paymentProviderId" => nil,
          "redirectUrl" => nil,
          "registered" => nil,
          "uri" => nil,
          "userId" => nil,
          "userPaymentMethodStatus" => nil
        },
        "productGroupUri" => %{"uri" => nil},
        "uri" => "/api/platform/user/65473025/orders/75382498"
      }

      %HTTPotion.Response{status_code: 200, body: Jason.encode!(json)}
    end)

    assert terminate_order_signed(123, @config) == {:ok, 123}
  end

  test "terminate order fails" do
    HTTPClientMock
    |> expect(:get, fn "https://vimond-rest-api.example.com/api/platform/order/123",
                       Accept: "application/json; v=3; charset=UTF-8",
                       "Content-Type": "application/json; v=3; charset=UTF-8",
                       Authorization: "SUMO key:" <> _,
                       Date: "Wed, 02 Sep 2015 13:24:35 +0000" ->
      json = %{
        "extendedTime" => nil,
        "startDate" => 1_509_001_257_000,
        "originalPrice" => nil,
        "userId" => 65_473_025,
        "productGroupId" => 7,
        "isp" => "TV4",
        "extUserId" => nil,
        "period" => 2_592_000,
        "id" => 75_382_498,
        "upgradeOrderId" => nil,
        "initPrice" => nil,
        "accessEndDate" => 1_511_593_257_000,
        "platformId" => 7,
        "ip" => "193.14.163.194",
        "autorenewStatus" => "NOT_ELIGIBLE",
        "productName" => "TV4 Play Premium Månad",
        "referrer" => "telia TVE",
        "endDate" => 1_511_593_257_000,
        "paymentInfoExpiryDate" => nil,
        "currency" => nil,
        "orderRef" => nil,
        "price" => 99.0,
        "upgradeOption" => nil,
        "notifyUserOnCreation" => nil,
        "appName" => nil,
        "status" => "ACTIVE",
        "paymentObject" => nil,
        "discount" => nil,
        "voucherCode" => nil,
        "productPaymentId" => 2548,
        "productId" => 1314,
        "categoryId" => nil,
        "earliestEndDate" => 1_509_001_257_000,
        "autorenewErrors" => nil,
        "deviceInfo" => %{"present" => false},
        "userPaymentMethod" => %{
          "allowOneClickBuy" => nil,
          "callbackUrl" => nil,
          "captureAttemptLog" => nil,
          "expirationDate" => nil,
          "expireDate" => nil,
          "extAgreementRef" => nil,
          "id" => nil,
          "paymentInfo" => nil,
          "paymentProviderId" => nil,
          "redirectUrl" => nil,
          "registered" => nil,
          "uri" => nil,
          "userId" => nil,
          "userPaymentMethodStatus" => nil
        },
        "productGroupUri" => %{"uri" => nil},
        "callbackUrl" => nil,
        "paymentInfo" => nil,
        "progId" => nil,
        "paymentProviderId" => nil,
        "autoRenewStopDate" => nil,
        "assetName" => nil,
        "uri" => "/api/platform/user/65473025/orders/75382498"
      }

      %HTTPotion.Response{
        status_code: 200,
        body: Jason.encode!(json)
      }
    end)

    HTTPClientMock
    |> expect(:put, fn "https://vimond-rest-api.example.com/api/platform/order/123",
                       body,
                       Accept: "application/json; v=3; charset=UTF-8",
                       "Content-Type": "application/json; v=3; charset=UTF-8",
                       Authorization: "SUMO key:" <> _,
                       Date: "Wed, 02 Sep 2015 13:24:35 +0000" ->
      assert Jason.decode!(body) == %{
               "accessEndDate" => 1_441_200_275_000,
               "autorenewStatus" => "NOT_ELIGIBLE",
               "earliestEndDate" => 1_509_001_257_000,
               "endDate" => 1_441_200_275_000,
               "id" => 75_382_498,
               "ip" => "193.14.163.194",
               "isp" => "TV4",
               "period" => 2_592_000,
               "platformId" => 7,
               "price" => 99.0,
               "productGroupId" => 7,
               "productId" => 1314,
               "productName" => "TV4 Play Premium Månad",
               "productPaymentId" => 2548,
               "referrer" => "telia TVE",
               "startDate" => 1_509_001_257_000,
               "status" => "ACTIVE",
               "uri" => "/api/platform/user/65473025/orders/75382498",
               "userId" => 65_473_025
             }

      %HTTPotion.Response{status_code: 400, body: Jason.encode!(%{})}
    end)

    assert terminate_order_signed(123, @config) == {:error, 123}
  end
end
