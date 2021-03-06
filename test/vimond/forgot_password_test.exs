defmodule Vimond.Client.ForgotPasswordTest do
  use ExUnit.Case, async: true
  alias Vimond.Config
  import Vimond.Client
  import Hammox

  setup :verify_on_exit!

  @config %Config{base_url: "https://vimond-rest-api.example.com/api/platform/"}

  test "with an existing username" do
    Vimond.HTTPClientMock
    |> expect(
      :delete,
      fn "user/user@example.com/password",
         [
           Accept: "application/json; v=3; charset=UTF-8",
           "Content-Type": "application/json; v=3; charset=UTF-8"
         ],
         @config ->
        %Vimond.Response{body: "", status_code: 204}
      end
    )

    assert forgot_password("user@example.com", @config) ==
             {:ok, %{message: "Reset password email sent"}}
  end

  test "with nonexisting user" do
    Vimond.HTTPClientMock
    |> expect(
      :delete,
      fn "user/user@example.com/password",
         [
           Accept: "application/json; v=3; charset=UTF-8",
           "Content-Type": "application/json; v=3; charset=UTF-8"
         ],
         @config ->
        %Vimond.Response{
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
          headers: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8"
          }
        }
      end
    )

    assert forgot_password("user@example.com", @config) ==
             {:error,
              %{
                type: :user_not_found,
                source_errors: ["No user with email user@example.com"]
              }}
  end

  test "with unexpected json" do
    Vimond.HTTPClientMock
    |> expect(
      :delete,
      fn "user/user@example.com/password",
         [
           Accept: "application/json; v=3; charset=UTF-8",
           "Content-Type": "application/json; v=3; charset=UTF-8"
         ],
         @config ->
        %Vimond.Response{
          status_code: 404,
          body: "",
          headers: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8"
          }
        }
      end
    )

    assert forgot_password("user@example.com", @config) ==
             {:error, %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
  end

  test "with unexpected error" do
    Vimond.HTTPClientMock
    |> expect(
      :delete,
      fn "user/user@example.com/password",
         [
           Accept: "application/json; v=3; charset=UTF-8",
           "Content-Type": "application/json; v=3; charset=UTF-8"
         ],
         @config ->
        %Vimond.Response{
          status_code: 500,
          body: Jason.encode!(%{"error" => %{"code" => "UNEXPECTED_ERROR"}}),
          headers: %{
            "content-type" => "application/json; v=\"2\";charset=UTF-8"
          }
        }
      end
    )

    assert forgot_password("user@example.com", @config) ==
             {:error, %{type: :generic, source_errors: ["Unexpected error"]}}
  end
end
