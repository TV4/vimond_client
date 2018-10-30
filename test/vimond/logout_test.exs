defmodule Vimond.Client.LogoutTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  use Fake

  test "with any token" do
    http_client =
      fake HTTPClient do
        def delete(
              "https://vimond-rest-api.example.com/api/authentication/user/logout",
              Accept: "application/json; v=3; charset=UTF-8",
              "Content-Type": "application/json; v=3; charset=UTF-8",
              Authorization: "Bearer vimond_authorization_token",
              Cookie: "rememberMe=valid_or_invalid_remember_me"
            ) do
          %HTTPotion.Response{
            status_code: 200,
            body:
              Jason.encode!(%{
                "code" => "SESSION_INVALIDATED",
                "description" => "Session invalidated",
                "reference" => "2ae4a65131783eb2",
                "status" => 200
              }),
            headers: %HTTPotion.Headers{
              hdrs: %{"content-type" => "application/json; v=3;charset=UTF-8"}
            }
          }
        end
      end

    assert logout("vimond_authorization_token", "valid_or_invalid_remember_me", http_client) ==
             {:ok, %{message: "User logged out"}}
  end

  test "handles errors" do
    http_client =
      fake HTTPClient do
        def delete(_url, _headers), do: %HTTPotion.ErrorResponse{message: "Because reason"}
      end

    assert logout("vimond_down_error", "remember_me", http_client) ==
             {:error, %{type: :http_error, source_errors: ["Because reason"]}}
  end

  test "handles invalid JSON responses from Vimond" do
    http_client =
      fake HTTPClient do
        def delete(_url, _headers) do
          %HTTPotion.Response{
            status_code: 200,
            body: "not_json",
            headers: %HTTPotion.Headers{
              hdrs: %{"content-type" => "application/json; v=3;charset=UTF-8"}
            }
          }
        end
      end

    assert logout("invalid_vimond_json", "remember_me", http_client) ==
             {:error,
              %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
  end
end
