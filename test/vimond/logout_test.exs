defmodule Vimond.Client.LogoutTest do
  use ExUnit.Case, async: true
  alias Vimond.Config
  import Vimond.Client
  import Mox

  setup :verify_on_exit!

  @config %Config{base_url: "https://vimond-rest-api.example.com/api/platform/"}

  test "with any token" do
    Vimond.HTTPClientMock
    |> expect(:delete, fn "https://vimond-rest-api.example.com/api/authentication/user/logout",
                          Accept: "application/json; v=3; charset=UTF-8",
                          "Content-Type": "application/json; v=3; charset=UTF-8",
                          Authorization: "Bearer vimond_authorization_token",
                          Cookie: "rememberMe=valid_or_invalid_remember_me" ->
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
    end)

    assert logout("vimond_authorization_token", "valid_or_invalid_remember_me", @config) ==
             {:ok, %{message: "User logged out"}}
  end

  test "handles errors" do
    Vimond.HTTPClientMock
    |> expect(:delete, fn _url, _headers ->
      %HTTPotion.ErrorResponse{message: "Because reason"}
    end)

    assert logout("vimond_down_error", "remember_me", @config) ==
             {:error, %{type: :http_error, source_errors: ["Because reason"]}}
  end

  test "handles invalid JSON responses from Vimond" do
    Vimond.HTTPClientMock
    |> expect(:delete, fn _url, _headers ->
      %HTTPotion.Response{
        status_code: 200,
        body: "not_json",
        headers: %HTTPotion.Headers{
          hdrs: %{"content-type" => "application/json; v=3;charset=UTF-8"}
        }
      }
    end)

    assert logout("invalid_vimond_json", "remember_me", @config) ==
             {:error,
              %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
  end
end
