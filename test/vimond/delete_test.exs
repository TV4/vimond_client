defmodule Vimond.Client.DeleteTest do
  use ExUnit.Case, async: true
  alias Vimond.Config
  import Vimond.Client
  import Hammox

  setup :verify_on_exit!

  @config %Config{
    base_url: "https://vimond-rest-api.example.com/api/platform/",
    api_key: "key",
    api_secret: "apisecret"
  }

  describe "user authenticated" do
    test "with a valid session" do
      Vimond.HTTPClientMock
      |> expect(:delete, fn "user/12345",
                            [
                              Accept: "application/json; v=3; charset=UTF-8",
                              "Content-Type": "application/json; v=3; charset=UTF-8",
                              Authorization: "Bearer blah"
                            ],
                            @config ->
        %Vimond.Response{
          body: "",
          headers: %{
            "authorization" => [
              "Bearer ecbc5af7-f50e-4853-8852-2f484e449e92",
              "Bearer ecbc5af7-f50e-4853-8852-2f484e449e92"
            ],
            "connection" => "keep-alive",
            "date" => "Mon, 07 May 2018 11:03:00 GMT",
            "server" => "Apache-Coyote/1.1",
            "set-cookie" =>
              "JSESSIONID=2681c00654e664bfa3418335d21a8199e3f9796b~33AA3932A7E40E6984433543FB758B22; Path=/api/; HttpOnly",
            "via" => "1.1 10f829d037cedbccf7e2d171413666c7.cloudfront.net (CloudFront)",
            "x-amz-cf-id" => "AI7efPJiVchnfl1Yy1ZrwbffGQVFF1QSDLvSnYP527SX36j_H3Oeyw==",
            "x-cache" => "Miss from cloudfront"
          },
          status_code: 204
        }
      end)

      assert delete("12345", "blah", @config) == {:ok, %{message: "User has been deleted"}}
    end

    test "with a valid session struct" do
      Vimond.HTTPClientMock
      |> expect(:delete, fn "user/12345",
                            [
                              Accept: "application/json; v=3; charset=UTF-8",
                              "Content-Type": "application/json; v=3; charset=UTF-8",
                              Authorization: "Bearer blah",
                              Cookie: "JSESSIONID=hejsessionid"
                            ],
                            @config ->
        %Vimond.Response{
          body: "",
          headers: %{
            "authorization" => [
              "Bearer ecbc5af7-f50e-4853-8852-2f484e449e92",
              "Bearer ecbc5af7-f50e-4853-8852-2f484e449e92"
            ],
            "connection" => "keep-alive",
            "date" => "Mon, 07 May 2018 11:03:00 GMT",
            "server" => "Apache-Coyote/1.1",
            "set-cookie" =>
              "JSESSIONID=2681c00654e664bfa3418335d21a8199e3f9796b~33AA3932A7E40E6984433543FB758B22; Path=/api/; HttpOnly",
            "via" => "1.1 10f829d037cedbccf7e2d171413666c7.cloudfront.net (CloudFront)",
            "x-amz-cf-id" => "AI7efPJiVchnfl1Yy1ZrwbffGQVFF1QSDLvSnYP527SX36j_H3Oeyw==",
            "x-cache" => "Miss from cloudfront"
          },
          status_code: 204
        }
      end)

      assert delete(
               "12345",
               %Vimond.Session{vimond_authorization_token: "blah", vimond_jsessionid: "hejsessionid"},
               @config
             ) == {:ok, %{message: "User has been deleted"}}
    end

    test "with an invalid session" do
      Vimond.HTTPClientMock
      |> expect(:delete, fn "user/12345",
                            [
                              Accept: "application/json; v=3; charset=UTF-8",
                              "Content-Type": "application/json; v=3; charset=UTF-8",
                              Authorization: "Bearer blah"
                            ],
                            @config ->
        %Vimond.Response{
          body:
            %{
              "error" => %{
                "code" => "NOT_AUTHORIZED",
                "description" => "The permission 'user:UPDATE' is required to execute the requested action",
                "id" => "1004",
                "reference" => "fe5a524a7a8a2864"
              }
            }
            |> Jason.encode!(),
          headers: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8"
          },
          status_code: 401
        }
      end)

      assert delete("12345", "blah", @config) ==
               {:error,
                %{
                  type: :invalid_session,
                  source_errors: [
                    "The permission 'user:UPDATE' is required to execute the requested action"
                  ]
                }}
    end

    test "with an expired session" do
      Vimond.HTTPClientMock
      |> expect(:delete, fn "user/12345",
                            [
                              Accept: "application/json; v=3; charset=UTF-8",
                              "Content-Type": "application/json; v=3; charset=UTF-8",
                              Authorization: "Bearer blah"
                            ],
                            @config ->
        data = %{
          error: %{
            code: "NOT_AUTHORIZED",
            description: "The permission 'user:UPDATE' is required to execute the requested action",
            id: "1004",
            reference: "e48e991db4ba7545"
          }
        }

        %Vimond.Response{
          body: Jason.encode!(data),
          headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"},
          status_code: 401
        }
      end)

      assert delete("12345", "blah", @config) ==
               {:error,
                %{
                  type: :invalid_session,
                  source_errors: ["The permission 'user:UPDATE' is required to execute the requested action"]
                }}
    end
  end

  describe "app authenticated" do
    test "succeeds" do
      Vimond.HTTPClientMock
      |> expect(:delete_signed, fn "user/12345",
                                   [
                                     Accept: "application/json; v=3; charset=UTF-8",
                                     "Content-Type": "application/json; v=3; charset=UTF-8"
                                   ],
                                   @config ->
        %Vimond.Response{
          body: "",
          headers: %{
            "set-cookie" => [
              "rememberMe=deleteMe; Path=/api; Max-Age=0; Expires=Tue, 02-Oct-2018 06:48:31 GMT",
              "sumoSession=:::3BoiBFh41RDnkGEzlpsQEQ!!; Domain=.b17g.net; Path=/; Max-Age=31536000; Expires=Thu, 03-Oct-2019 06:48:31 GMT; HttpOnly",
              "sumoSession=deleteMe; Domain=.b17g.net; Path=/; Max-Age=0; Expires=Tue, 02-Oct-2018 06:48:31 GMT",
              "sumoSession=deleteMe; Path=/; Max-Age=0; Expires=Tue, 02-Oct-2018 06:48:31 GMT",
              "JSESSIONID=279bfc7ef205a173cb552c8ac90a542d860f62a2~C334E42FAE28CB6A47E8AAD79E754CF6; Path=/api/; HttpOnly"
            ]
          },
          status_code: 204
        }
      end)

      assert delete_signed("12345", @config) == {:ok, %{message: "User has been deleted"}}
    end

    test "when the user does not exist" do
      Vimond.HTTPClientMock
      |> expect(:delete_signed, fn _path, _headers, _config ->
        %Vimond.Response{
          body:
            Jason.encode!(%{
              "error" => %{
                "code" => "USER_NOT_FOUND",
                "description" => nil,
                "id" => "1023"
              }
            }),
          headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"},
          status_code: 404
        }
      end)

      assert delete_signed("12345", @config) == {:error, %{type: :user_not_found, source_errors: ["USER_NOT_FOUND"]}}
    end

    test "with unexpected error" do
      Vimond.HTTPClientMock
      |> expect(:delete_signed, fn _path, _headers, _config ->
        %Vimond.Error{message: "Oh noes!"}
      end)

      assert delete_signed("12345", @config) == {:error, %{type: :generic, source_errors: ["Unexpected error"]}}
    end
  end
end
