defmodule Vimond.Client.UserIdByEmailTest do
  use ExUnit.Case
  import Vimond.Client
  import Hammox

  setup :verify_on_exit!

  @config %Vimond.Config{
    base_url: "https://vimond-rest-api.example.com/api/platform/",
    api_key: "key",
    api_secret: "secret"
  }

  describe "app authenticated" do
    test "with valid credentials" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "user/some.person@example.com",
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        json = %{
          "country" => "SWE",
          "email" => "some.person@example.com",
          "firstName" => "Some",
          "id" => 6_572_908,
          "lastName" => "Person",
          "properties" => [],
          "registrationDate" => "2018-05-07T11:05:01Z",
          "uri" => "/api/platform/user/6572908",
          "userName" => "some.person@example.com"
        }

        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %{"content-type" => "application/json; v=\"2\";charset=UTF-8"}
        }
      end)

      assert user_id_by_email_signed("some.person@example.com", @config) ==
               {:ok, 6_572_908}
    end

    test "failure to authenticate against vimond" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "user/some.person@example.com",
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        json = %{
          "code" => "AUTHENTICATION_FAILED"
        }

        %Vimond.Response{
          status_code: 401,
          body: Jason.encode!(json),
          headers: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8"
          }
        }
      end)

      assert user_id_by_email_signed("some.person@example.com", @config) ==
               {:error, %{source_errors: ["{\"code\":\"AUTHENTICATION_FAILED\"}"], type: :invalid_credentials}}
    end

    test "error contacting Vimond" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "user/some.person@example.com",
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        %Vimond.Error{message: "econnrefused"}
      end)

      assert user_id_by_email_signed("some.person@example.com", @config) ==
               {:error, %{source_errors: ["%Vimond.Error{message: \"econnrefused\"}"], type: :unknown_error}}
    end
  end
end
