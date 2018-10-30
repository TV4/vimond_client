defmodule Vimond.Client.ProductTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  use Fake

  test "with product that has description" do
    http_client =
      fake HTTPClient do
        def get(
              "https://vimond-rest-api.example.com/api/platform/productgroup/1083/products/1400",
              Accept: "application/json; v=3; charset=UTF-8",
              "Content-Type": "application/json; v=3; charset=UTF-8"
            ) do
          %HTTPotion.Response{
            status_code: 200,
            body: Jason.encode!(%{description: "C More Premium"}),
            headers: %HTTPotion.Headers{
              hdrs: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
            }
          }
        end
      end

    assert product(1083, 1400, http_client) == {:ok, %{description: "C More Premium"}}
  end

  test "with product that doesn't have description" do
    http_client =
      fake HTTPClient do
        def get(
              "https://vimond-rest-api.example.com/api/platform/productgroup/1083/products/1400",
              Accept: "application/json; v=3; charset=UTF-8",
              "Content-Type": "application/json; v=3; charset=UTF-8"
            ) do
          %HTTPotion.Response{
            status_code: 200,
            body: Jason.encode!(%{}),
            headers: %HTTPotion.Headers{
              hdrs: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
            }
          }
        end
      end

    assert product(1083, 1400, http_client) == {:ok, %{description: nil}}
  end
end
