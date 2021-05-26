defmodule Vimond.Client.ReauthenticateTest do
  use ExUnit.Case, async: true
  alias Vimond.{Config, Session}
  import Vimond.Client
  import Hammox

  setup :verify_on_exit!

  @config %Config{
    base_url: "https://vimond-rest-api.example.com/api/platform/"
  }

  test "with valid session" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "/api/authentication/user",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8",
                         Authorization: "Bearer authentication_token",
                         Cookie: "rememberMe=valid_remember_me"
                       ],
                       @config ->
      %Vimond.Response{
        body:
          %{
            "code" => "SESSION_AUTHENTICATED",
            "description" => "Authenticated session",
            "reference" => "172050df6173503f",
            "status" => 200,
            "userId" => 100_059_309
          }
          |> Jason.encode!(),
        headers: %{
          "authorization" => "Bearer d800ec18-0dea-47cf-9101-690d286637c7",
          "content-type" => "application/json; v=3;charset=UTF-8"
        },
        status_code: 200
      }
    end)

    assert reauthenticate("authentication_token", "valid_remember_me", @config) ==
             {:ok,
              %{
                session: %Vimond.Session{
                  vimond_authorization_token: "d800ec18-0dea-47cf-9101-690d286637c7"
                }
              }}
  end

  test "with JSESSIONID in addition to authentication token" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "/api/authentication/user",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8",
                         Authorization: "Bearer authentication_token",
                         Cookie: "rememberMe=valid_remember_me",
                         Cookie: "JSESSIONID=vimond_jsessionid"
                       ],
                       @config ->
      %Vimond.Response{
        body:
          %{
            "code" => "SESSION_AUTHENTICATED",
            "description" => "Authenticated session",
            "reference" => "172050df6173503f",
            "status" => 200,
            "userId" => 100_059_309
          }
          |> Jason.encode!(),
        headers: %{
          "authorization" => "Bearer d800ec18-0dea-47cf-9101-690d286637c7",
          "content-type" => "application/json; v=3;charset=UTF-8"
        },
        status_code: 200
      }
    end)

    assert reauthenticate("authentication_token", "valid_remember_me", "vimond_jsessionid", @config) ==
             {:ok,
              %{
                session: %Vimond.Session{
                  vimond_authorization_token: "d800ec18-0dea-47cf-9101-690d286637c7"
                }
              }}
  end

  test "with a Session struct as parameter" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "/api/authentication/user",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8",
                         Authorization: "Bearer authentication_token",
                         Cookie: "rememberMe=valid_remember_me",
                         Cookie: "JSESSIONID=vimond_jsessionid"
                       ],
                       @config ->
      %Vimond.Response{
        body:
          %{
            "code" => "SESSION_AUTHENTICATED",
            "description" => "Authenticated session",
            "reference" => "172050df6173503f",
            "status" => 200,
            "userId" => 100_059_309
          }
          |> Jason.encode!(),
        headers: %{
          "authorization" => "Bearer d800ec18-0dea-47cf-9101-690d286637c7",
          "content-type" => "application/json; v=3;charset=UTF-8",
          "set-cookie" => "JSESSIONID=vimond_jsessionid"
        },
        status_code: 200
      }
    end)

    assert reauthenticate(
             %Session{
               vimond_authorization_token: "authentication_token",
               vimond_remember_me: "valid_remember_me",
               vimond_jsessionid: "vimond_jsessionid"
             },
             @config
           ) ==
             {:ok,
              %{
                session: %Vimond.Session{
                  vimond_authorization_token: "d800ec18-0dea-47cf-9101-690d286637c7",
                  vimond_jsessionid: "vimond_jsessionid"
                }
              }}
  end

  test "with an expired session" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "/api/authentication/user",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8",
                         Authorization: "Bearer expired_authentication_token",
                         Cookie: "rememberMe=expired_remember_me"
                       ],
                       @config ->
      %Vimond.Response{
        status_code: 200,
        body:
          Jason.encode!(%{
            "code" => "SESSION_NOT_AUTHENTICATED",
            "description" => "Session is not authenticated",
            "reference" => "a24ceec0c04092cd",
            "status" => 200
          }),
        headers: %{
          "content-type" => "application/json; v=3;charset=UTF-8"
        }
      }
    end)

    assert reauthenticate("expired_authentication_token", "expired_remember_me", @config) ==
             {:error, %{type: :invalid_session, source_errors: ["Session is not authenticated"]}}
  end
end
