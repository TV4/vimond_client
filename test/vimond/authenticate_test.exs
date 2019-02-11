defmodule Vimond.Client.AuthenticateTest do
  use ExUnit.Case, async: true
  alias Vimond.Config
  import Vimond.Client
  import Mox

  setup :verify_on_exit!

  @config %Config{
    base_url: "https://vimond-rest-api.example.com/api/platform/"
  }

  test "with valid credentials" do
    Vimond.HTTPClientMock
    |> expect(:post, fn "/api/authentication/user/login",
                        body,
                        [
                          Accept: "application/json; v=3; charset=UTF-8",
                          "Content-Type": "application/json; v=2; charset=UTF-8"
                        ],
                        @config ->
      assert Jason.decode!(body) == %{
               "username" => "valid_user",
               "password" => "password",
               "rememberMe" => true,
               "platform" => "all",
               "expand" => "user"
             }

      %HTTPotion.Response{
        status_code: 200,
        body:
          Jason.encode!(%{
            "code" => "AUTHENTICATION_OK",
            "description" => "Authentication successful",
            "reference" => "ba5e8d5105be5ce7",
            "status" => 200,
            "user" => %{
              "dateOfBirth" => "1981-01-01T00:00:00Z",
              "email" => "some.person@example.com",
              "firstName" => "Valid",
              "id" => 6_572_908,
              "lastName" => "User",
              "userName" => "some.person@example.com",
              "zip" => "923 45"
            },
            "userId" => 6_572_908
          }),
        headers: %HTTPotion.Headers{
          hdrs: %{
            "content-type" => "application/json; v=3;charset=UTF-8",
            "authorization" => "Bearer valid_vimond_authorization_token",
            "set-cookie" => [
              "rememberMe=deleteMe; Path=/api; Max-Age=0; Expires=Mon, 13-Feb-2017 13:29:05 GMT",
              "rememberMe=VIMOND_REMEMBER_ME; Path=/api; Max-Age=31536000; Expires=Wed, 14-Feb-2018 13:29:05 GMT; HttpOnly"
            ]
          }
        }
      }
    end)

    assert authenticate("valid_user", "password", @config) ==
             {:ok,
              %{
                session: %Vimond.Session{
                  expires: 1_518_614_945,
                  vimond_authorization_token: "valid_vimond_authorization_token",
                  vimond_remember_me: "VIMOND_REMEMBER_ME"
                },
                user: %Vimond.User{
                  user_id: "6572908",
                  email: "some.person@example.com",
                  username: "some.person@example.com",
                  year_of_birth: 1981,
                  first_name: "Valid",
                  last_name: "User",
                  properties: [],
                  zip_code: "923 45"
                }
              }}
  end

  test "with invalid credentials" do
    Vimond.HTTPClientMock
    |> expect(:post, fn _path, _body, _headers, _config ->
      %HTTPotion.Response{
        status_code: 401,
        body:
          Jason.encode!(%{
            "code" => "AUTHENTICATION_FAILED",
            "description" => "Incorrect username or password",
            "reference" => "157e55a3a8e3b97e",
            "status" => 401
          }),
        headers: %HTTPotion.Headers{
          hdrs: %{"content-type" => "application/json; v=3;charset=UTF-8"}
        }
      }
    end)

    assert authenticate("valid_user", "wrong_password", @config) ==
             {:error,
              %{
                source_errors: ["Incorrect username or password"],
                type: :invalid_credentials
              }}
  end

  test "handles errors" do
    Vimond.HTTPClientMock
    |> expect(:post, fn _path, _body, _headers, _config ->
      %HTTPotion.Response{
        status_code: 200,
        body: Jason.encode!(%{"unexpected" => "value"}),
        headers: %HTTPotion.Headers{
          hdrs: %{"content-type" => "application/json; v=3;charset=UTF-8"}
        }
      }
    end)

    assert authenticate("error_user", "error_password", @config) ==
             {:error, %{type: :generic, source_errors: ["Unexpected error"]}}
  end
end
