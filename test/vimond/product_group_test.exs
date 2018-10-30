defmodule Vimond.Client.ProductGroupTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  use Fake

  test "with a product group that has a name" do
    http_client =
      fake HTTPClient do
        def get(
              "https://vimond-rest-api.example.com/api/platform/productgroup/1083",
              Accept: "application/json; v=3; charset=UTF-8",
              "Content-Type": "application/json; v=3; charset=UTF-8"
            ) do
          %HTTPotion.Response{
            status_code: 200,
            body: Jason.encode!(%{name: "C More Premium"}),
            headers: %HTTPotion.Headers{
              hdrs: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
            }
          }
        end
      end

    assert product_group(1083, http_client) == {:ok, %{name: "C More Premium"}}
  end

  test "with a product group that doesn't have a name" do
    http_client =
      fake HTTPClient do
        def get(
              "https://vimond-rest-api.example.com/api/platform/productgroup/1083",
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

    assert product_group(1083, http_client) == {:ok, %{name: nil}}
  end
end
