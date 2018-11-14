defmodule Vimond.Client.ExistsTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  import Mox

  setup :verify_on_exit!

  @config %Vimond.Config{
    api_key: "key",
    api_secret: "secret",
    base_url: "https://vimond-rest-api.example.com/api/platform/"
  }

  test "returns true for user existing in vimond" do
    Vimond.HTTPClientMock
    |> expect(
      :get,
      fn "https://vimond-rest-api.example.com/api/platform/user/username/existing@example.com",
         Accept: "application/json; v=3; charset=UTF-8",
         "Content-Type": "application/json; v=3; charset=UTF-8",
         Authorization: "SUMO key:" <> _generated_vimond_signature,
         Date: "Wed, 02 Sep 2015 13:24:35 +0000" ->
        %HTTPotion.Response{
          status_code: 200,
          body:
            Jason.encode!(%{
              "dateOfBirth" => "1970-01-01T01:00:00Z",
              "email" => "johan@adaptiv.se",
              "emailStatus" => 2,
              "firstName" => "Jo",
              "id" => 6_572_908,
              "lastName" => "Ha",
              "mobileStatus" => 0,
              "properties" => [],
              "registrationDate" => "2014-12-17T15:04:50Z",
              "uri" => "/api/platform/user/6572908",
              "userName" => "johan@adaptiv.se",
              "zip" => "12345"
            }),
          headers: %HTTPotion.Headers{
            hdrs: %{"content-type" => "application/json; v=3;charset=UTF-8"}
          }
        }
      end
    )

    assert exists_signed("existing@example.com", @config) == {:ok, %{exists: true}}
  end

  test "returns false for user that does not exist in vimond" do
    Vimond.HTTPClientMock
    |> expect(:get, fn _url,
                       Accept: "application/json; v=3; charset=UTF-8",
                       "Content-Type": "application/json; v=3; charset=UTF-8",
                       Authorization: "SUMO key:" <> _generated_vimond_signature,
                       Date: "Wed, 02 Sep 2015 13:24:35 +0000" ->
      %HTTPotion.Response{
        status_code: 400,
        body:
          Jason.encode!(%{
            "error" => %{
              "code" => "USER_INVALID_USERNAME",
              "description" => "The username 'whom@example.com' is not valid",
              "id" => "1024",
              "reference" => "b86ecc3d7b64cf37"
            }
          }),
        headers: %HTTPotion.Headers{
          hdrs: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
        }
      }
    end)

    assert exists_signed("whom@example.com", @config) == {:ok, %{exists: false}}
  end

  test "handles errors" do
    Vimond.HTTPClientMock
    |> expect(:get, fn _, _ -> %HTTPotion.ErrorResponse{message: "Oh noes!"} end)

    assert exists_signed("vimond_down_error", @config) ==
             {:error, %{type: :http_error, source_errors: ["Oh noes!"]}}
  end
end
