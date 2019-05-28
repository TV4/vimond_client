defmodule Vimond.Client.PaymentTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  import Mox
  import ExUnit.CaptureLog

  setup :verify_on_exit!

  @config %Vimond.Config{base_url: "https://vimond-rest-api.example.com/api/platform/"}

  test "with a product group with existing data" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "productgroup/0/products/0/productPayments/2793/payment",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %HTTPotion.Response{
        status_code: 200,
        body: Jason.encode!(%{paymentMethod: "KLARNA", url: "https://api.klarna.com"}),
        headers: %HTTPotion.Headers{
          hdrs: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
        }
      }
    end)

    assert payment(2793, @config) ==
             {:ok, %{payment_method: "KLARNA", url: "https://api.klarna.com"}}
  end

  test "with error from Vimond" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "productgroup/0/products/0/productPayments/2793/payment",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %HTTPotion.Response{status_code: 500}
    end)

    assert capture_log(fn ->
             assert payment(2793, @config) == {:error, "Failed to fetch payment"}
           end) =~ "handle_payment_response: Unexpected response"
  end
end
