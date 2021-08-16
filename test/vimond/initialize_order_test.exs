defmodule Vimond.Client.InitializeOrderTest do
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

  describe "initialize_order_signed" do
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

      assert initialize_order_signed("12345", order, @config) == {:ok, 1}
    end

    test "fails" do
      Vimond.HTTPClientMock
      |> expect(:post_signed, fn "order",
                                 body,
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
               assert initialize_order_signed("12345", order, @config) == {:error, :failed_to_initialize_order}
             end) =~ ~r/Error initializing order: %Vimond.Response/
    end
  end
end
