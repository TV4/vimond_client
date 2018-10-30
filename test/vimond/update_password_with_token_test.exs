defmodule Vimond.Client.UpdatePasswordWithTokenTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  use Fake

  test "with valid a valid password token and password" do
    http_client =
      fake HTTPClient do
        def post(
              "https://vimond-rest-api.example.com/api/platform/user/password",
              body,
              Accept: "application/json; v=3; charset=UTF-8",
              "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
            ) do
          %{"token" => "valid_password_token", "password" => "password"} = URI.decode_query(body)

          %HTTPotion.Response{
            status_code: 204,
            body: "",
            headers: %HTTPotion.Headers{
              hdrs: %{
                "content-type" => "application/json; v=\"3\";charset=UTF-8"
              }
            }
          }
        end
      end

    assert update_password_with_token("valid_password_token", "password", http_client) ==
             {:ok, %{}}
  end

  test "with expired password token" do
    http_client =
      fake HTTPClient do
        def post(
              "https://vimond-rest-api.example.com/api/platform/user/password",
              body,
              Accept: "application/json; v=3; charset=UTF-8",
              "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
            ) do
          %{"token" => "expired_password_token", "password" => "password"} =
            URI.decode_query(body)

          %HTTPotion.Response{
            status_code: 409,
            body:
              Jason.encode!(%{
                "error" => %{
                  "code" => "INVALID_TOKEN",
                  "description" => "Token has expired",
                  "id" => "1050",
                  "reference" => "4fc2b50cd99583a7"
                }
              }),
            headers: %HTTPotion.Headers{
              hdrs: %{
                "content-type" => "application/json; v=\"3\";charset=UTF-8"
              }
            }
          }
        end
      end

    assert update_password_with_token("expired_password_token", "password", http_client) ==
             {:error, %{type: :generic, source_errors: ["Token has expired"]}}
  end
end
