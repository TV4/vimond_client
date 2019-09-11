defmodule Vimond.Client.VoucherTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  import Mox

  setup :verify_on_exit!

  @config %Vimond.Config{base_url: "https://vimond-rest-api.example.com/api/platform"}

  test "with a voucher with existing data" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "/api/voucher/An-existing-voucher-code",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8",
                         "X-Forwarded-For": "5.6.7.8, 1.2.3.4"
                       ],
                       @config ->
      %HTTPotion.Response{
        status_code: 200,
        headers: %HTTPotion.Headers{},
        body:
          Jason.encode!(%{
            "allCodes" => ["An-existing-voucher-code"],
            "available" => false,
            "code" => "An-existing-voucher-code",
            "discountFractionRecurring" => 0.5,
            "discountType" => "FRACTION",
            "discountTypeString" => "FRACTION",
            "expiry" => "2020-08-30T22:00:00Z",
            "pool" => "Some-pool-identifier",
            "startDate" => "2018-11-14T23:00:00Z",
            "product" => %{
              "comment" => "99kr/mån, erbjudande för Blajkunder",
              "currency" => "SEK",
              "enabled" => true,
              "id" => 2420,
              "minimumPeriods" => 0,
              "paymentPlan" => %{
                "id" => 2,
                "name" => "Månad",
                "paymentType" => "SUBSCRIPTION",
                "period" => "PT2592000S"
              },
              "price" => 198.0,
              "productGroupId" => 1244,
              "productPaymentsUri" => %{},
              "productStatus" => "HIDDEN",
              "sortIndex" => 1
            },
            "productPaymentId" => 5442,
            "productPaymentIds" => [5442, 5443],
            "productPaymentUri" => %{},
            "products" => [
              %{
                "comment" => "99kr/mån, erbjudande för Blajkunder",
                "currency" => "SEK",
                "enabled" => true,
                "id" => 2420,
                "minimumPeriods" => 0,
                "paymentPlan" => %{
                  "id" => 2,
                  "name" => "Månad",
                  "paymentType" => "SUBSCRIPTION",
                  "period" => "PT2592000S"
                },
                "price" => 198.0,
                "productGroupId" => 1244,
                "productPaymentsUri" => %{},
                "productStatus" => "HIDDEN",
                "sortIndex" => 1
              },
              %{
                "comment" => "99kr/mån, erbjudande för Blajkunder",
                "currency" => "SEK",
                "enabled" => true,
                "id" => 2420,
                "minimumPeriods" => 0,
                "paymentPlan" => %{
                  "id" => 2,
                  "name" => "Månad",
                  "paymentType" => "SUBSCRIPTION",
                  "period" => "PT2592000S"
                },
                "price" => 198.0,
                "productGroupId" => 1244,
                "productPaymentsUri" => %{},
                "productStatus" => "HIDDEN",
                "sortIndex" => 1
              }
            ],
            "usages" => 1,
            "userUri" => %{},
            "voucherType" => "SINGLE",
            "voucherTypeString" => "SINGLE"
          })
      }
    end)

    assert voucher("An-existing-voucher-code", "5.6.7.8, 1.2.3.4", @config) ==
             {:ok,
              %Vimond.Voucher{
                code: "An-existing-voucher-code",
                pool: "Some-pool-identifier",
                usages: 1,
                start_at: "2018-11-14T23:00:00Z",
                end_at: "2020-08-30T22:00:00Z",
                product_id: 2420
              }}
  end

  test "when missing start date" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "/api/voucher/An-existing-voucher-code",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8",
                         "X-Forwarded-For": "5.6.7.8, 1.2.3.4"
                       ],
                       @config ->
      %HTTPotion.Response{
        status_code: 200,
        headers: %HTTPotion.Headers{},
        body:
          Jason.encode!(%{
            "code" => "An-existing-voucher-code",
            "expiry" => "2020-08-30T22:00:00Z",
            "pool" => "Some-pool-identifier",
            "product" => %{
              "id" => 2420
            },
            "usages" => 1
          })
      }
    end)

    assert voucher("An-existing-voucher-code", "5.6.7.8, 1.2.3.4", @config) ==
             {:ok,
              %Vimond.Voucher{
                code: "An-existing-voucher-code",
                pool: "Some-pool-identifier",
                usages: 1,
                start_at: nil,
                end_at: "2020-08-30T22:00:00Z",
                product_id: 2420
              }}
  end

  test "when the voucher does not exist" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "/api/voucher/A-missing-voucher-code",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8",
                         "X-Forwarded-For": "5.6.7.8, 1.2.3.4"
                       ],
                       @config ->
      %HTTPotion.Response{
        status_code: 404,
        headers: %HTTPotion.Headers{},
        body:
          Jason.encode!(%{
            error: %{
              id: "1005",
              code: "URL_NOT_FOUND",
              description: "Voucher with code 'A-missing-voucher-code' was not found",
              reference: "790c425bd35336f8"
            }
          })
      }
    end)

    assert voucher("A-missing-voucher-code", "5.6.7.8, 1.2.3.4", @config) ==
             {:error,
              %{type: :voucher_not_found, source_errors: ["Voucher with code 'A-missing-voucher-code' was not found"]}}
  end
end
