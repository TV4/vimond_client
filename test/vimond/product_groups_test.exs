defmodule Vimond.Client.ProductGroupsTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  import Mox
  import ExUnit.CaptureLog

  setup :verify_on_exit!

  @config %Vimond.Config{base_url: "https://vimond-rest-api.example.com/api/platform/"}

  test "product groups" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "productgroup",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %HTTPotion.Response{
        status_code: 200,
        body:
          Jason.encode!(%{
            productGroups: [
              %{name: "C More Premium", description: "C More TV4", saleStatus: "ENABLED"},
              %{name: "C More", description: "C More", saleStatus: "ENABLED"}
            ]
          }),
        headers: %HTTPotion.Headers{
          hdrs: %{"content-type" => "application/json;v=\"3\";charset=UTF-8"}
        }
      }
    end)

    assert product_groups(@config) ==
             {:ok,
              [
                %{name: "C More Premium", description: "C More TV4", sale_status: "ENABLED"},
                %{name: "C More", description: "C More", sale_status: "ENABLED"}
              ]}
  end

  test "with error from Vimond" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "productgroup",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %HTTPotion.Response{status_code: 500}
    end)

    assert capture_log(fn ->
             assert product_groups(@config) == {:error, "Failed to fetch product groups"}
           end) =~ "handle_product_groups_response: Unexpected response"
  end
end