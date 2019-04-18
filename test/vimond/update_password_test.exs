defmodule Vimond.Client.UpdatePasswordTest do
  use ExUnit.Case, async: true
  alias Vimond.Config
  import Vimond.Client
  import Mox

  setup :verify_on_exit!

  @config %Config{
    base_url: "https://vimond-rest-api.example.com/api/platform/"
  }

  test "with valid parameters" do
    Vimond.HTTPClientMock
    |> expect(:put, fn "user/password",
                       body,
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8",
                         Authorization: "Bearer vimond_authorization_token",
                         Cookie: "rememberMe=remember_me"
                       ],
                       @config ->
      ExUnit.Assertions.assert(
        Jason.decode!(body) == %{
          "userId" => 12345,
          "oldPassword" => "old_password",
          "newPassword" => "new_password"
        }
      )

      %HTTPotion.Response{
        status_code: 204,
        body: "",
        headers: %HTTPotion.Headers{
          hdrs: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8"
          }
        }
      }
    end)

    assert update_password(
             "12345",
             "vimond_authorization_token",
             "remember_me",
             "old_password",
             "new_password",
             @config
           ) == {:ok, %{}}
  end

  test "with wrong password" do
    Vimond.HTTPClientMock
    |> expect(:put, fn "user/password", _body, _headers, _config ->
      %HTTPotion.Response{
        status_code: 409,
        body:
          Jason.encode!(%{
            "error" => %{
              "code" => "USER_INVALID_PASSWORD",
              "description" => "Old password is incorrect",
              "id" => "1025",
              "reference" => "aa15278261be1cd0"
            }
          }),
        headers: %HTTPotion.Headers{
          hdrs: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8"
          }
        }
      }
    end)

    update_password_response =
      update_password(
        "12345",
        "vimond_authorization_token",
        "remember_me",
        "old_password",
        "new_password",
        @config
      )

    assert update_password_response ==
             {:error, %{type: :invalid_credentials, source_errors: ["Old password is incorrect"]}}
  end

  test "with an expired remember me token" do
    Vimond.HTTPClientMock
    |> expect(:put, fn "user/password", _body, _headers, _config ->
      %HTTPotion.Response{
        status_code: 401,
        body:
          Jason.encode!(%{
            "error" => %{
              "code" => "UNAUTHORIZED",
              "description" => "User can only update profile of self",
              "id" => "1049",
              "reference" => "32e9730e2bf1ea1d"
            }
          }),
        headers: %HTTPotion.Headers{
          hdrs: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8"
          }
        }
      }
    end)

    expected =
      {:error, %{type: :invalid_session, source_errors: ["User can only update profile of self"]}}

    assert update_password(
             "12345",
             "vimond_authorization_token",
             "remember_me",
             "old_password",
             "new_password",
             @config
           ) == expected
  end
end
