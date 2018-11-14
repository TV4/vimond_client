defmodule Vimond.Client.AddOrderTest do
  use ExUnit.Case, async: true
  alias Vimond.Config
  import Vimond.Client
  import ExUnit.CaptureLog
  import Mox

  setup :verify_on_exit!

  @config %Config{
    base_url: "https://vimond-rest-api.example.com/api/platform/",
    api_key: "key",
    api_secret: "apisecret"
  }

  describe "add_order_signed" do
    test "succeeds" do
      Vimond.HTTPClientMock
      |> expect(:post, fn "https://vimond-rest-api.example.com/api/platform/order/12345/create",
                          body,
                          Accept: "application/json; v=3; charset=UTF-8",
                          "Content-Type": "application/json; v=3; charset=UTF-8",
                          Authorization: "SUMO key:" <> _,
                          Date: "Wed, 02 Sep 2015 13:24:35 +0000" ->
        %{
          "productPaymentId" => 4224,
          "referrer" => "telia OTT-B2B",
          "startDate" => 1_441_200_275_000
        } = Jason.decode!(body)

        %HTTPotion.Response{status_code: 200, body: Jason.encode!(%{"id" => 123})}
      end)

      order = %Vimond.Order{product_payment_id: 4224, referrer: "telia OTT-B2B"}

      assert add_order_signed("12345", order, @config) == {:ok, 123}
    end

    test "fails" do
      Vimond.HTTPClientMock
      |> expect(:post, fn "https://vimond-rest-api.example.com/api/platform/order/12345/create",
                          body,
                          Accept: "application/json; v=3; charset=UTF-8",
                          "Content-Type": "application/json; v=3; charset=UTF-8",
                          Authorization: "SUMO key:" <> _,
                          Date: "Wed, 02 Sep 2015 13:24:35 +0000" ->
        %{
          "productPaymentId" => 11111,
          "referrer" => "telia OTT-B2B",
          "startDate" => 1_441_200_275_000
        } = body |> Jason.decode!()

        json = %{
          "code" => "PRODUCT_PAYMENT_NOT_FOUND",
          "description" => "No ProductPayment with id 11111"
        }

        %HTTPotion.Response{status_code: 404, body: Jason.encode!(json)}
      end)

      order = %Vimond.Order{product_payment_id: 11111, referrer: "telia OTT-B2B"}

      assert capture_log(fn ->
               assert add_order_signed("12345", order, @config) == {:error, :failed_to_add_order}
             end) =~ ~r/Error adding order: %HTTPotion.Response/
    end
  end
end
