defmodule Vimond.Client.OrderPaymentTest do
  use ExUnit.Case, async: true
  alias Vimond.Config
  import Vimond.Client
  import ExUnit.CaptureLog
  import Hammox

  setup :verify_on_exit!

  @config %Config{
    base_url: "https://vimond-rest-api.example.com/api/platform/",
    api_key: "key",
    api_secret: "apisecret"
  }

  describe "initialize_order_payment_signed" do
    test "succeeds" do
      Vimond.HTTPClientMock
      |> expect(:post_signed, fn "order",
                                 body,
                                 [
                                   Accept: "application/json; v=3; charset=UTF-8",
                                   "Content-Type": "application/json; v=3; charset=UTF-8"
                                 ],
                                 @config ->
        assert Jason.decode!(body) == %{
                 "userId" => 12345,
                 "productPaymentId" => 4224
               }

        response_body = %{
          "currency" => "NOK",
          "referrer" => nil,
          "statusText" => "Purchase initialized",
          "orderRef" => "0",
          "vat" => nil,
          "voucherCode" => nil,
          "extUserId" => nil,
          "ip" => "x.x.x.x",
          "productName" => "Sumo Basis Ãr",
          "userStopDate" => nil,
          "paymentMethod" => "CREDITCARD",
          "autoRenewStopDate" => nil,
          "extendedTime" => nil,
          "upgradeDiscount" => nil,
          "upgradeOption" => nil,
          "upgradeExtendedTime" => nil,
          "appName" => nil,
          "trialOverride" => "DEFAULT",
          "status" => "INITIALIZE",
          "userId" => 1,
          "paymentProvider" => nil,
          "paymentObject" => %{
            "timestamp" => nil,
            "provider" => nil,
            "description" => nil,
            "url" => "https://test.epayment.nets.eu/...",
            "paymentMethod" => "CREDITCARD",
            "password" => nil,
            "token" => nil,
            "redirectUrl" => %{
              "uri" => nil
            },
            "baseUrl" => nil,
            "callbackUri" => %{
              "uri" => nil
            },
            "initializeUri" => %{
              "uri" => nil
            },
            "paymentType" => nil,
            "orderId" => nil,
            "providerReturnUrl" => nil,
            "expireMonth" => nil,
            "expireYear" => nil,
            "cvc" => nil,
            "mobilenumber" => nil,
            "countrycode" => nil,
            "authString" => nil,
            "externalUserId" => nil,
            "pin" => nil,
            "externalPaymentForms" => nil,
            "externalReference" => nil,
            "appId" => nil,
            "resetUrl" => nil,
            "callbackFail" => nil,
            "callbackRedirect" => nil,
            "callbackOpen" => nil,
            "callbackNotification" => nil,
            "callbackVerifyOrder" => nil,
            "paymentMethodAction" => nil,
            "terminalDesign" => nil,
            "generateClientToken" => nil,
            "callbackOk" => nil,
            "pinCode" => nil,
            "voucher" => nil,
            "htmlForm" => nil,
            "callbackForm" => nil,
            "cardNumber" => nil,
            "verificationCode" => nil,
            "mobileOperatorCode" => nil,
            "klarnaEmail" => nil,
            "customerToken" => nil,
            "deviceData" => nil,
            "nonce" => nil,
            "endUserIp" => nil,
            "name" => "Bankkort",
            "uri" => nil
          },
          "productUri" => nil,
          "productGroupUri" => %{
            "uri" => nil
          },
          "price" => 899.0,
          "paymentProviderId" => nil,
          "startDate" => 1,
          "endDate" => 1,
          "autorenewStatus" => "NOT_STARTED",
          "activePeriods" => 1,
          "autorenewErrors" => 0,
          "accessEndDate" => 1,
          "earliestEndDate" => 1,
          "productGroupId" => 12,
          "progId" => nil,
          "platform" => nil,
          "platformId" => 1,
          "categoryId" => nil,
          "productPaymentId" => 328,
          "initPrice" => 899.0,
          "period" => %{
            "fixed" => false,
            "zero" => false
          },
          "productId" => 80,
          "userPaymentMethod" => %{
            "currency" => nil,
            "expirationDate" => nil,
            "userPaymentMethodType" => nil,
            "allowOneClickBuy" => nil,
            "redirectUrl" => nil,
            "captureAttemptLog" => nil,
            "userId" => nil,
            "paymentProviderId" => nil,
            "expireDate" => nil,
            "extAgreementRef" => nil,
            "userPaymentMethodStatus" => nil,
            "paymentInfo" => nil,
            "registered" => nil,
            "callbackUrl" => nil,
            "id" => nil,
            "uri" => nil
          },
          "paymentInfo" => nil,
          "isp" => nil,
          "registered" => 1,
          "notifyUserOnCreation" => nil,
          "upgradeOrderId" => nil,
          "externalOrderRef" => nil,
          "paymentInfoExpiryDate" => nil,
          "assetName" => nil,
          "originalPrice" => nil,
          "deviceInfo" => %{
            "present" => false
          },
          "changeAction" => "NEW",
          "discount" => nil,
          "callbackUrl" => nil,
          "productPaymentUri" => nil,
          "id" => 1,
          "uri" => nil
        }

        %Vimond.Response{status_code: 200, body: Jason.encode!(response_body)}
      end)

      order = %Vimond.Order{product_payment_id: 4224, referrer: "telia OTT-B2B"}

      assert initialize_order_payment_signed("12345", order, @config) ==
               {:ok, %{order_id: 1, payment_url: "https://test.epayment.nets.eu/..."}}
    end

    test "fails" do
      Vimond.HTTPClientMock
      |> expect(:post_signed, fn "order",
                                 _body,
                                 [
                                   Accept: "application/json; v=3; charset=UTF-8",
                                   "Content-Type": "application/json; v=3; charset=UTF-8"
                                 ],
                                 @config ->
        json = %{
          "code" => "11111",
          "description" => "MOCKED RESPONSE"
        }

        %Vimond.Response{status_code: 404, body: Jason.encode!(json)}
      end)

      order = %Vimond.Order{product_payment_id: 4224, referrer: "telia OTT-B2B"}

      assert capture_log(fn ->
               assert initialize_order_payment_signed("12345", order, @config) ==
                        {:error, :failed_to_initialize_order_payment}
             end) =~ ~r/Error initializing order payment: %Vimond.Response/
    end
  end

  describe "complete_order_payment_signed" do
    test "succeeds" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "order/callback?orderId=100521864&...",
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        response_body =
          %{
            "id" => 100_521_864,
            "startDate" => "2021-07-13T16:08:28Z",
            "autorenewErrors" => 0,
            "platformId" => 27,
            "endDate" => "2021-07-14T16:08:28Z",
            "orderRef" => "100344858",
            "status" => "ACTIVE",
            "paymentInfoExpiryDate" => "2024-01-01T00:00:00Z",
            "period" => "PT86400S",
            "userPaymentMethod" => %{
              "allowOneClickBuy" => true,
              "expirationDate" => "2024-01-01T00:00:00Z",
              "expireDate" => "2024-01-01T00:00:00Z",
              "extAgreementRef" => "667296977",
              "id" => "57533d54-95f6-4ace-9d4b-22aaa6231298",
              "paymentInfo" => "4571 10** **** 0000",
              "paymentProviderId" => 33,
              "registered" => "2021-07-13T16:08:41Z",
              "userId" => 100_586_798,
              "userPaymentMethodStatus" => "ACTIVE",
              "userPaymentMethodType" => "CREDIT_CARD"
            },
            "productGroupId" => 1009,
            "productName" => "Premium Plus 24 h",
            "trialOverride" => "DEFAULT",
            "paymentInfo" => "4571 10** **** 0000",
            "externalOrderRef" => "667296977",
            "ip" => "78.69.123.215",
            "currency" => "SEK",
            "productPaymentUri" => %{
              "uri" => "/api/cse/productgroup/1009/products/3080/productPayments/6203"
            },
            "activePeriods" => 1,
            "productPaymentId" => 6203,
            "registered" => "2021-07-13T16:08:28Z",
            "productGroupUri" => %{"uri" => "/api/cse/productgroup/1009"},
            "accessEndDate" => "2021-07-14T16:08:28Z",
            "initPrice" => 1.0,
            "productUri" => %{"uri" => "/api/cse/productgroup/1009/products/3080"},
            "vat" => 0.0,
            "autorenewStatus" => "NOT_ELIGIBLE",
            "userId" => 100_586_798,
            "price" => 1.0,
            "earliestEndDate" => "2021-07-14T16:08:28Z",
            "statusText" => "Purchase sucessfull",
            "productId" => 3080,
            "uri" => "/api/cse/order/100521864"
          }
          |> Jason.encode!()

        %Vimond.Response{status_code: 200, body: response_body}
      end)

      assert complete_order_payment_signed("orderId=100521864&...", @config) == {:ok, 100_521_864}
    end

    test "fails" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "order/callback?orderId=100521864&...",
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        json = %{
          "code" => "11111",
          "description" => "MOCKED RESPONSE"
        }

        %Vimond.Response{status_code: 404, body: Jason.encode!(json)}
      end)

      assert capture_log(fn ->
               assert complete_order_payment_signed("orderId=100521864&...", @config) ==
                        {:error, :failed_to_complete_order_payment}
             end) =~ ~r/Error completing order payment: %Vimond.Response/
    end
  end
end
