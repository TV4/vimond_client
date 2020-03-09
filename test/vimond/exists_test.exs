defmodule Vimond.Client.ExistsTest do
  use ExUnit.Case, async: true
  import Vimond.Client
  import Hammox

  setup :verify_on_exit!

  @config %Vimond.Config{
    api_key: "key",
    api_secret: "secret",
    base_url: "https://vimond-rest-api.example.com/api/platform/"
  }

  test "returns true for user existing in vimond" do
    Vimond.HTTPClientMock
    |> expect(
      :get_signed,
      fn "user/username/existing@example.com",
         [
           Accept: "application/json; v=3; charset=UTF-8",
           "Content-Type": "application/json; v=3; charset=UTF-8"
         ],
         @config ->
        %Vimond.Response{
          status_code: 200,
          body:
            Jason.encode!(%{
              "dateOfBirth" => "1970-01-01T01:00:00Z",
              "email" => "johan@adaptiv.se",
              "emailStatus" => 2,
              "firstName" => "Jo",
              "id" => 6_572_908,
              "lastName" => "Ha",
              "mobileStatus" => 0,
              "properties" => [],
              "registrationDate" => "2014-12-17T15:04:50Z",
              "uri" => "/api/platform/user/6572908",
              "userName" => "johan@adaptiv.se",
              "zip" => "12345"
            }),
          headers: %{"content-type" => "application/json; v=3;charset=UTF-8"}
        }
      end
    )

    assert exists_signed("existing@example.com", @config) == {:ok, %{exists: true}}
  end

  describe "with different username and email" do
    test "lookup by username" do
      Vimond.HTTPClientMock
      |> expect(
        :get_signed,
        fn "user/username/johan",
           [
             Accept: "application/json; v=3; charset=UTF-8",
             "Content-Type": "application/json; v=3; charset=UTF-8"
           ],
           @config ->
          %Vimond.Response{
            status_code: 200,
            body:
              Jason.encode!(%{
                "dateOfBirth" => "1970-01-01T01:00:00Z",
                "email" => "existing@example.com",
                "emailStatus" => 2,
                "firstName" => "Jo",
                "id" => 6_572_908,
                "lastName" => "Ha",
                "mobileStatus" => 0,
                "properties" => [],
                "registrationDate" => "2014-12-17T15:04:50Z",
                "uri" => "/api/platform/user/6572908",
                "userName" => "johan",
                "zip" => "12345"
              }),
            headers: %{"content-type" => "application/json; v=3;charset=UTF-8"}
          }
        end
      )

      assert exists_signed("johan", @config) == {:ok, %{exists: true}}
    end

    test "lookup by email" do
      Vimond.HTTPClientMock
      |> expect(
        :get_signed,
        fn "user/username/existing@example.com",
           [
             Accept: "application/json; v=3; charset=UTF-8",
             "Content-Type": "application/json; v=3; charset=UTF-8"
           ],
           @config ->
          %Vimond.Response{
            status_code: 400,
            body:
              Jason.encode!(%{
                "error" => %{
                  "code" => "USER_INVALID_USERNAME",
                  "description" => "The username 'existing@example.com' is not valid",
                  "id" => "1024",
                  "reference" => "b86ecc3d7b64cf37"
                }
              }),
            headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
          }
        end
      )
      |> expect(
        :get_signed,
        fn "user/existing@example.com",
           [
             Accept: "application/json; v=3; charset=UTF-8",
             "Content-Type": "application/json; v=3; charset=UTF-8"
           ],
           @config ->
          %Vimond.Response{
            status_code: 200,
            body:
              Jason.encode!(%{
                "dateOfBirth" => "1970-01-01T01:00:00Z",
                "email" => "existing@example.com",
                "emailStatus" => 2,
                "firstName" => "Jo",
                "id" => 6_572_908,
                "lastName" => "Ha",
                "mobileStatus" => 0,
                "properties" => [],
                "registrationDate" => "2014-12-17T15:04:50Z",
                "uri" => "/api/platform/user/6572908",
                "userName" => "johan",
                "zip" => "12345"
              }),
            headers: %{"content-type" => "application/json; v=3;charset=UTF-8"}
          }
        end
      )

      assert exists_signed("existing@example.com", @config) == {:ok, %{exists: true}}
    end
  end

  test "returns false for user that does not exist in vimond" do
    Vimond.HTTPClientMock
    |> expect(:get_signed, 2, fn _url,
                                 [
                                   Accept: "application/json; v=3; charset=UTF-8",
                                   "Content-Type": "application/json; v=3; charset=UTF-8"
                                 ],
                                 @config ->
      %Vimond.Response{
        status_code: 400,
        body:
          Jason.encode!(%{
            "error" => %{
              "code" => "USER_INVALID_USERNAME",
              "description" => "The username 'whom@example.com' is not valid",
              "id" => "1024",
              "reference" => "b86ecc3d7b64cf37"
            }
          }),
        headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
      }
    end)

    assert exists_signed("whom@example.com", @config) == {:ok, %{exists: false}}
  end

  test "handles errors" do
    Vimond.HTTPClientMock
    |> expect(:get_signed, fn _, _, _ -> %Vimond.Error{message: "Oh noes!"} end)

    assert exists_signed("kalle", @config) ==
             {:error, %{type: :http_error, source_errors: ["Oh noes!"]}}

    Vimond.HTTPClientMock
    |> expect(:get_signed, fn _, _, _ -> %Vimond.Response{status_code: 400} end)
    |> expect(:get_signed, fn _, _, _ -> %Vimond.Error{message: "Oh noes!"} end)

    assert exists_signed("kalle@example.com", @config) ==
             {:error, %{type: :http_error, source_errors: ["Oh noes!"]}}
  end
end
