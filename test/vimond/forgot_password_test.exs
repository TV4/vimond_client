defmodule Vimond.Client.ForgotPasswordTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  import Mox

  setup :verify_on_exit!

  test "with an existing username" do
    HTTPClientMock
    |> expect(
      :delete,
      fn "https://vimond-rest-api.example.com/api/platform/user/user@example.com/password",
         Accept: "application/json; v=3; charset=UTF-8",
         "Content-Type": "application/json; v=3; charset=UTF-8" ->
        %HTTPotion.Response{body: "", headers: %HTTPotion.Headers{}, status_code: 204}
      end
    )

    assert forgot_password("user@example.com") == {:ok, %{message: "Reset password email sent"}}
  end

  test "with nonexisting user" do
    HTTPClientMock
    |> expect(
      :delete,
      fn "https://vimond-rest-api.example.com/api/platform/user/user@example.com/password",
         Accept: "application/json; v=3; charset=UTF-8",
         "Content-Type": "application/json; v=3; charset=UTF-8" ->
        %HTTPotion.Response{
          status_code: 404,
          body:
            Jason.encode!(%{
              "error" => %{
                "code" => "USER_NOT_FOUND",
                "description" => "No user with email user@example.com",
                "id" => "1023",
                "reference" => "f83c168502b7ec02"
              }
            }),
          headers: %HTTPotion.Headers{
            hdrs: %{
              "content-type" => "application/json; v=\"3\";charset=UTF-8"
            }
          }
        }
      end
    )

    assert forgot_password("user@example.com") ==
             {:error,
              %{
                type: :user_not_found,
                source_errors: ["No user with email user@example.com"]
              }}
  end

  test "with unexpected json" do
    HTTPClientMock
    |> expect(
      :delete,
      fn "https://vimond-rest-api.example.com/api/platform/user/user@example.com/password",
         Accept: "application/json; v=3; charset=UTF-8",
         "Content-Type": "application/json; v=3; charset=UTF-8" ->
        %HTTPotion.Response{
          status_code: 404,
          body: "",
          headers: %HTTPotion.Headers{
            hdrs: %{
              "content-type" => "application/json; v=\"3\";charset=UTF-8"
            }
          }
        }
      end
    )

    assert forgot_password("user@example.com") ==
             {:error,
              %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
  end

  test "with unexpected error" do
    HTTPClientMock
    |> expect(
      :delete,
      fn "https://vimond-rest-api.example.com/api/platform/user/user@example.com/password",
         Accept: "application/json; v=3; charset=UTF-8",
         "Content-Type": "application/json; v=3; charset=UTF-8" ->
        %HTTPotion.Response{
          status_code: 500,
          body: Jason.encode!(%{"error" => %{"code" => "UNEXPECTED_ERROR"}}),
          headers: %HTTPotion.Headers{
            hdrs: %{
              "content-type" => "application/json; v=\"2\";charset=UTF-8"
            }
          }
        }
      end
    )

    assert forgot_password("user@example.com") ==
             {:error, %{type: :generic, source_errors: ["Unexpected error"]}}
  end
end
