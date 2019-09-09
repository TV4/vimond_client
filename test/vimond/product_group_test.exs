defmodule Vimond.Client.ProductGroupTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  import Mox
  import ExUnit.CaptureLog

  setup :verify_on_exit!

  @config %Vimond.Config{base_url: "https://vimond-rest-api.example.com/api/platform/"}

  test "with a product group with existing data" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "productgroup/1083",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %HTTPotion.Response{
        status_code: 200,
        body:
          Jason.encode!(%{
            id: 1083,
            name: "C More Premium",
            description: "C More TV4",
            saleStatus: "ENABLED"
          }),
        headers: %HTTPotion.Headers{
          hdrs: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
        }
      }
    end)

    assert product_group(1083, @config) ==
             {:ok,
              %Vimond.ProductGroup{id: 1083, name: "C More Premium", description: "C More TV4", sale_status: "ENABLED"}}
  end

  test "with broken JSON from Vimond" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "productgroup/1083",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %HTTPotion.Response{status_code: 200, body: "br|ok3n/JaS0n"}
    end)

    assert capture_log(fn ->
             assert product_group(1083, @config) == {:error, "Failed to parse product group"}
           end) =~ "handle_product_group_response: Unexpected json"
  end

  test "with error from Vimond" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "productgroup/1083",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %HTTPotion.Response{status_code: 500}
    end)

    assert capture_log(fn ->
             assert product_group(1083, @config) == {:error, "Failed to fetch product group"}
           end) =~ "handle_product_group_response: Unexpected response"
  end
end
