defmodule Vimond.Client.ReauthenticateTest do
  use ExUnit.Case, async: true
  alias Vimond.Config
  import Vimond.Client
  import Mox

  setup :verify_on_exit!

  @config %Config{
    base_url: "https://vimond-rest-api.example.com/api/platform/"
  }

  test "with valid 'remember me'" do
    HTTPClientMock
    |> expect(:get, fn "https://vimond-rest-api.example.com/api/authentication/user",
                       Accept: "application/json; v=3; charset=UTF-8",
                       "Content-Type": "application/json; v=3; charset=UTF-8",
                       Cookie: "rememberMe=valid_remember_me" ->
      %HTTPotion.Response{
        body:
          %{
            "code" => "SESSION_AUTHENTICATED",
            "description" => "Authenticated session",
            "reference" => "172050df6173503f",
            "status" => 200,
            "userId" => 100_059_309
          }
          |> Jason.encode!(),
        headers: %HTTPotion.Headers{
          hdrs: %{
            "authorization" => "Bearer d800ec18-0dea-47cf-9101-690d286637c7",
            "content-type" => "application/json; v=3;charset=UTF-8"
          }
        },
        status_code: 200
      }
    end)

    assert reauthenticate("valid_remember_me", @config) ==
             {:ok,
              %{
                session: %Vimond.Session{
                  vimond_authorization_token: "d800ec18-0dea-47cf-9101-690d286637c7"
                }
              }}
  end

  test "with an expired 'remember me'" do
    HTTPClientMock
    |> expect(:get, fn _url, _headers ->
      %HTTPotion.Response{
        status_code: 200,
        body:
          Jason.encode!(%{
            "code" => "SESSION_NOT_AUTHENTICATED",
            "description" => "Session is not authenticated",
            "reference" => "a24ceec0c04092cd",
            "status" => 200
          }),
        headers: %HTTPotion.Headers{
          hdrs: %{
            "content-type" => "application/json; v=3;charset=UTF-8"
          }
        }
      }
    end)

    assert reauthenticate("expired_remember_me", @config) ==
             {:error, %{type: :invalid_session, source_errors: ["Session is not authenticated"]}}
  end
end
