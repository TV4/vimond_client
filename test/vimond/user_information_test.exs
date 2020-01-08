defmodule Vimond.Client.UserInformationTest do
  use ExUnit.Case
  import Vimond.Client
  import Mox

  setup :verify_on_exit!

  @config %Vimond.Config{
    base_url: "https://vimond-rest-api.example.com/api/platform/",
    api_key: "key",
    api_secret: "secret"
  }

  describe "user authenticated" do
    test "with valid credentials" do
      Vimond.HTTPClientMock
      |> expect(:get, fn "user",
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8",
                           Authorization: "Bearer valid_authorization_token",
                           Cookie: "rememberMe=valid_remember_me"
                         ],
                         @config ->
        json = %{
          "mobileNumber" => "0712345678",
          "dateOfBirth" => "1981-01-01T00:00:00Z",
          "email" => "some.person@example.com",
          "firstName" => "Valid",
          "id" => 6_572_908,
          "lastName" => "User",
          "properties" => [
            %{
              "hidden" => false,
              "id" => 7_445_317,
              "name" => "user_property_c",
              "userId" => 16_426_403,
              "value" => "2016-05-20"
            },
            %{
              "hidden" => false,
              "id" => 7_445_318,
              "name" => "user_property_d",
              "userId" => 16_426_403,
              "value" => "2016-06-17 09:26:17 UTC"
            },
            %{
              "hidden" => false,
              "id" => 7_445_319,
              "name" => "user_property_a",
              "userId" => 16_426_403,
              "value" => "2018-05-25"
            },
            %{
              "hidden" => false,
              "id" => 7_445_320,
              "name" => "user_property_b",
              "userId" => 16_426_403,
              "value" => "2018-05-26 08:34:37 UTC"
            }
          ],
          "registrationDate" => "2018-05-07T11:05:01Z",
          "uri" => "/api/platform/user/6572908",
          "userName" => "some.person@example.com",
          "zip" => "923 45"
        }

        %HTTPotion.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %HTTPotion.Headers{
            hdrs: %{
              "authorization" => [
                "Bearer valid_authorization_token",
                "Bearer valid_authorization_token"
              ],
              "content-type" => "application/json; v=3;charset=UTF-8"
            }
          }
        }
      end)

      assert user_information("valid_authorization_token", "valid_remember_me", @config) == {
               :ok,
               %{
                 user: %Vimond.User{
                   user_id: "6572908",
                   email: "some.person@example.com",
                   username: "some.person@example.com",
                   first_name: "Valid",
                   last_name: "User",
                   zip_code: "923 45",
                   country_code: nil,
                   year_of_birth: 1981,
                   properties: [
                     %Vimond.Property{
                       id: 7_445_319,
                       name: "user_property_a",
                       value: "2018-05-25"
                     },
                     %Vimond.Property{
                       id: 7_445_320,
                       name: "user_property_b",
                       value: "2018-05-26 08:34:37 UTC"
                     },
                     %Vimond.Property{
                       id: 7_445_317,
                       name: "user_property_c",
                       value: "2016-05-20"
                     },
                     %Vimond.Property{
                       id: 7_445_318,
                       name: "user_property_d",
                       value: "2016-06-17 09:26:17 UTC"
                     }
                   ]
                 },
                 session: %Vimond.Session{
                   vimond_authorization_token: "valid_authorization_token"
                 }
               }
             }
    end

    test "with invalid Vimond authorization token and valid remember_me" do
      Vimond.HTTPClientMock
      |> expect(:get, fn _path, _headers, _config ->
        json = %{
          "mobileNumber" => "0712345678",
          "dateOfBirth" => "1981-01-01T00:00:00Z",
          "email" => "some.person@example.com",
          "firstName" => "Valid",
          "id" => 6_572_908,
          "lastName" => "User",
          "properties" => [
            %{
              "hidden" => false,
              "id" => 7_445_317,
              "name" => "user_property_c",
              "userId" => 16_426_403,
              "value" => "2016-05-20"
            },
            %{
              "hidden" => false,
              "id" => 7_445_318,
              "name" => "user_property_d",
              "userId" => 16_426_403,
              "value" => "2016-06-17 09:26:17 UTC"
            },
            %{
              "hidden" => false,
              "id" => 7_445_319,
              "name" => "user_property_a",
              "userId" => 16_426_403,
              "value" => "2018-05-25"
            },
            %{
              "hidden" => false,
              "id" => 7_445_320,
              "name" => "user_property_b",
              "userId" => 16_426_403,
              "value" => "2018-05-26 08:34:37 UTC"
            }
          ],
          "registrationDate" => "2018-05-07T11:05:01Z",
          "uri" => "/api/platform/user/6572908",
          "userName" => "some.person@example.com",
          "zip" => "923 45"
        }

        %HTTPotion.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %HTTPotion.Headers{
            hdrs: %{
              "content-type" => "application/json; v=\"3\";charset=UTF-8",
              "authorization" => "Bearer renewed_authorization_token"
            }
          }
        }
      end)

      assert user_information("invalid_vimond_authorization_token", "valid_remember_me", @config) ==
               {:ok,
                %{
                  user: %Vimond.User{
                    user_id: "6572908",
                    email: "some.person@example.com",
                    username: "some.person@example.com",
                    first_name: "Valid",
                    last_name: "User",
                    year_of_birth: 1981,
                    zip_code: "923 45",
                    country_code: nil,
                    properties: [
                      %Vimond.Property{
                        id: 7_445_319,
                        name: "user_property_a",
                        value: "2018-05-25"
                      },
                      %Vimond.Property{
                        id: 7_445_320,
                        name: "user_property_b",
                        value: "2018-05-26 08:34:37 UTC"
                      },
                      %Vimond.Property{
                        id: 7_445_317,
                        name: "user_property_c",
                        value: "2016-05-20"
                      },
                      %Vimond.Property{
                        id: 7_445_318,
                        name: "user_property_d",
                        value: "2016-06-17 09:26:17 UTC"
                      }
                    ]
                  },
                  session: %Vimond.Session{
                    vimond_authorization_token: "renewed_authorization_token"
                  }
                }}
    end

    test "with invalid credentials" do
      Vimond.HTTPClientMock
      |> expect(:get, fn _path, _headers, _config ->
        json = %{
          "error" => %{
            "code" => "SESSION_NOT_AUTHENTICATED",
            "description" => "User is not authenticated",
            "id" => "1044",
            "reference" => "575d0b4b5518ece7",
            "status" => 401
          }
        }

        %HTTPotion.Response{
          status_code: 401,
          body: Jason.encode!(json),
          headers: %HTTPotion.Headers{
            hdrs: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
          }
        }
      end)

      expected = {:error, %{type: :invalid_session, source_errors: ["User is not authenticated"]}}

      assert user_information(
               "invalid_vimond_authorization_token",
               "invalid_remember_me",
               @config
             ) == expected
    end

    test "with an unknown response" do
      Vimond.HTTPClientMock
      |> expect(:get, fn _path, _headers, _config ->
        json = %{
          "error" => %{
            "code" => "I_DONT_KNOW_WHATS_GOING_ON",
            "description" => "User is not authenticated",
            "id" => "1044",
            "reference" => "575d0b4b5518ece7",
            "status" => 401
          }
        }

        %HTTPotion.Response{
          status_code: 401,
          body: Jason.encode!(json),
          headers: %HTTPotion.Headers{
            hdrs: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
          }
        }
      end)

      expected = {:error, %{type: :generic, source_errors: ["Unexpected error"]}}

      assert user_information("uncategorized_error", "crazy_remember_me", @config) == expected
    end
  end

  describe "app authenticated" do
    test "with valid credentials" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "user/12345",
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        json = %{
          "mobileNumber" => "0712345678",
          "dateOfBirth" => "1981-01-01T00:00:00Z",
          "email" => "some.person@example.com",
          "firstName" => "Valid",
          "id" => 6_572_908,
          "lastName" => "User",
          "properties" => [],
          "registrationDate" => "2018-05-07T11:05:01Z",
          "uri" => "/api/platform/user/6572908",
          "userName" => "some.person@example.com",
          "zip" => "923 45"
        }

        %HTTPotion.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %HTTPotion.Headers{
            hdrs: %{"content-type" => "application/json; v=\"2\";charset=UTF-8"}
          }
        }
      end)
      |> expect(:get_signed, fn "user/12345/properties",
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        json = [
          %{
            "hidden" => false,
            "id" => 7_445_317,
            "name" => "user_property_c",
            "userId" => 16_426_403,
            "value" => "2016-05-20"
          },
          %{
            "hidden" => false,
            "id" => 7_445_318,
            "name" => "user_property_d",
            "userId" => 16_426_403,
            "value" => "2016-06-17 09:26:17 UTC"
          },
          %{
            "hidden" => false,
            "id" => 7_445_319,
            "name" => "user_property_a",
            "userId" => 16_426_403,
            "value" => "2018-05-25"
          },
          %{
            "hidden" => false,
            "id" => 7_445_320,
            "name" => "user_property_b",
            "userId" => 16_426_403,
            "value" => "2018-05-26 08:34:37 UTC"
          }
        ]

        %HTTPotion.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %HTTPotion.Headers{
            hdrs: %{"content-type" => "application/json; v=\"2\";charset=UTF-8"}
          }
        }
      end)

      assert user_information_signed("12345", @config) ==
               {:ok,
                %{
                  :user => %Vimond.User{
                    user_id: "6572908",
                    username: "some.person@example.com",
                    email: "some.person@example.com",
                    first_name: "Valid",
                    last_name: "User",
                    zip_code: "923 45",
                    country_code: nil,
                    year_of_birth: 1981,
                    properties: [
                      %Vimond.Property{
                        id: 7_445_319,
                        name: "user_property_a",
                        value: "2018-05-25"
                      },
                      %Vimond.Property{
                        id: 7_445_320,
                        name: "user_property_b",
                        value: "2018-05-26 08:34:37 UTC"
                      },
                      %Vimond.Property{
                        id: 7_445_317,
                        name: "user_property_c",
                        value: "2016-05-20"
                      },
                      %Vimond.Property{
                        id: 7_445_318,
                        name: "user_property_d",
                        value: "2016-06-17 09:26:17 UTC"
                      }
                    ]
                  }
                }}
    end

    test "failure to authenticate against vimond" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "user/12345",
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        json = %{
          "code" => "AUTHENTICATION_FAILED",
          "description" => "No account found for 'key'",
          "id" => "1043",
          "reference" => "de09d5a6c4310260",
          "status" => 401
        }

        %HTTPotion.Response{
          status_code: 401,
          body: Jason.encode!(json),
          headers: %HTTPotion.Headers{
            hdrs: %{
              "content-type" => "application/json; v=\"3\";charset=UTF-8"
            }
          }
        }
      end)

      assert user_information_signed("12345", @config) ==
               {:error, %{source_errors: ["Unexpected error"], type: :generic}}
    end

    test "error contacting Vimond" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "user/12345",
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        %HTTPotion.ErrorResponse{message: "econnrefused"}
      end)

      assert user_information_signed("12345", @config) ==
               {:error, %{source_errors: ["econnrefused"], type: :http_error}}
    end
  end
end
