defmodule Vimond.Client.UpdateUserTest do
  use ExUnit.Case
  import Vimond.Client
  import Mox

  setup :verify_on_exit!

  @config %Vimond.Config{base_url: "https://vimond-rest-api.example.com/api/platform/"}

  describe "user authenticated" do
    test "when replacing a property and keeping a property" do
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
          "address" => nil,
          "city" => nil,
          "confirmEmail" => nil,
          "country" => nil,
          "dateOfBirth" => "1981-01-01T00:00:00Z",
          "email" => "old@example.com",
          "emailStatus" => 2,
          "firstName" => "Valid",
          "gender" => nil,
          "id" => 6_572_908,
          "infoRestricted" => nil,
          "lastName" => "User",
          "mobileNumber" => "0730236645",
          "mobileStatus" => 0,
          "nick" => nil,
          "notifyUserOnCreation" => nil,
          "password" => nil,
          "properties" => [
            %{
              "hidden" => false,
              "id" => 7_445_318,
              "name" => "user_property_d",
              "uri" => nil,
              "userId" => 16_426_403,
              "value" => "2016-06-17 09:26:17 UTC"
            },
            %{
              "hidden" => false,
              "id" => 7_445_317,
              "name" => "user_property_c",
              "uri" => nil,
              "userId" => 16_426_403,
              "value" => "2016-05-20"
            },
            %{
              "hidden" => false,
              "id" => 7_445_319,
              "name" => "user_property_a",
              "uri" => nil,
              "userId" => 16_426_403,
              "value" => "2018-05-25"
            },
            %{
              "hidden" => false,
              "id" => 7_445_320,
              "name" => "user_property_b",
              "uri" => nil,
              "userId" => 16_426_403,
              "value" => "2018-05-26 08:34:37 UTC"
            }
          ],
          "receiveEmail" => nil,
          "receiveSms" => nil,
          "registrationDate" => 1_418_828_690_000,
          "state" => nil,
          "status" => nil,
          "uri" => "/api/platform/user/6572908",
          "userName" => "old@example.com",
          "userType" => nil,
          "zip" => "123 45"
        }

        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %{
            "content-type" => "application/json; v=\"2\";charset=UTF-8",
            "authorization" => "Bearer valid_authorization_token"
          }
        }
      end)

      Vimond.HTTPClientMock
      |> expect(:put, fn "user",
                         body,
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8",
                           Authorization: "Bearer valid_authorization_token",
                           Cookie: "rememberMe=valid_remember_me"
                         ],
                         @config ->
        assert %{
                 "id" => 6_572_908,
                 "registrationDate" => 1_418_828_690_000,
                 "userName" => "some.person@example.com",
                 "email" => "some.person@example.com",
                 "emailStatus" => 2,
                 "firstName" => "Valid",
                 "lastName" => "User",
                 "zip" => "123 45",
                 "country" => "SWE",
                 "mobileNumber" => "0730236645",
                 "mobileStatus" => 0,
                 "dateOfBirth" => "1981-01-01",
                 "properties" => [
                   %{
                     "id" => 7_445_318,
                     "name" => "user_property_d",
                     "value" => "2016-06-17 09:26:17 UTC"
                   },
                   %{
                     "id" => 7_445_317,
                     "name" => "user_property_c",
                     "value" => "2016-05-20"
                   },
                   %{
                     "id" => 7_445_319,
                     "name" => "user_property_a",
                     "value" => "2018-09-02"
                   },
                   %{
                     "id" => 7_445_320,
                     "name" => "user_property_b",
                     "value" => "2015-09-02"
                   }
                 ]
               } == Jason.decode!(body)

        json = %{
          "address" => nil,
          "city" => nil,
          "confirmEmail" => nil,
          "country" => "SWE",
          "dateOfBirth" => "1981-01-01T00:00:00Z",
          "email" => "some.person@example.com",
          "emailStatus" => 2,
          "firstName" => "Valid",
          "gender" => nil,
          "id" => 6_572_908,
          "infoRestricted" => nil,
          "lastName" => "User",
          "mobileNumber" => "0730236645",
          "mobileStatus" => 0,
          "nick" => nil,
          "notifyUserOnCreation" => nil,
          "password" => nil,
          "properties" => [
            %{
              "id" => 7_445_318,
              "name" => "user_property_d",
              "value" => "2016-06-17 09:26:17 UTC"
            },
            %{
              "id" => 7_445_317,
              "name" => "user_property_c",
              "value" => "2016-05-20"
            },
            %{
              "id" => 7_445_319,
              "name" => "user_property_a",
              "value" => "2018-09-02"
            },
            %{
              "id" => 7_445_320,
              "name" => "user_property_b",
              "value" => "2015-09-02"
            }
          ],
          "receiveEmail" => nil,
          "receiveSms" => nil,
          "registrationDate" => 1_418_828_690_000,
          "state" => nil,
          "status" => nil,
          "uri" => "/api/platform/user/6572908",
          "userName" => "some.person@example.com",
          "userType" => nil,
          "zip" => "123 45"
        }

        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %{
            "content-type" => "application/json; v=3;charset=UTF-8",
            "authorization" => "Bearer valid_authorization_token"
          }
        }
      end)

      user = %Vimond.User{
        username: "some.person@example.com",
        first_name: "Valid",
        last_name: "User",
        zip_code: "123 45",
        country_code: "SWE",
        year_of_birth: 1981,
        properties: [
          %Vimond.Property{name: "user_property_a", value: "2018-09-02"},
          %Vimond.Property{name: "user_property_b", value: "2015-09-02"}
        ]
      }

      assert update("valid_authorization_token", "valid_remember_me", "6572908", user, @config) ==
               {:ok,
                %{
                  user: %Vimond.User{
                    user_id: "6572908",
                    username: "some.person@example.com",
                    email: "some.person@example.com",
                    first_name: "Valid",
                    last_name: "User",
                    zip_code: "123 45",
                    country_code: "SWE",
                    year_of_birth: 1981,
                    properties: [
                      %Vimond.Property{
                        id: 7_445_319,
                        name: "user_property_a",
                        value: "2018-09-02"
                      },
                      %Vimond.Property{
                        id: 7_445_320,
                        name: "user_property_b",
                        value: "2015-09-02"
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
                  session: %Vimond.Session{}
                }}
    end

    test "when adding a property and keeping a property" do
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
          "address" => nil,
          "city" => nil,
          "confirmEmail" => nil,
          "country" => nil,
          "dateOfBirth" => "1981-01-01T00:00:00Z",
          "email" => "old@example.com",
          "emailStatus" => 2,
          "firstName" => "Valid",
          "gender" => nil,
          "id" => 6_572_908,
          "infoRestricted" => nil,
          "lastName" => "User",
          "mobileNumber" => "0730236645",
          "mobileStatus" => 0,
          "nick" => nil,
          "notifyUserOnCreation" => nil,
          "password" => nil,
          "properties" => [
            %{
              "hidden" => false,
              "id" => 7_445_317,
              "name" => "user_property_c",
              "uri" => nil,
              "userId" => 16_426_403,
              "value" => "2016-05-20"
            },
            %{
              "hidden" => false,
              "id" => 7_445_318,
              "name" => "user_property_d",
              "uri" => nil,
              "userId" => 16_426_403,
              "value" => "2016-06-17 09:26:17 UTC"
            }
          ],
          "receiveEmail" => nil,
          "receiveSms" => nil,
          "registrationDate" => 1_418_828_690_000,
          "state" => nil,
          "status" => nil,
          "uri" => "/api/platform/user/6572908",
          "userName" => "old@example.com",
          "userType" => nil,
          "zip" => "123 45"
        }

        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %{
            "content-type" => "application/json; v=3;charset=UTF-8",
            "authorization" => "Bearer valid_authorization_token"
          }
        }
      end)

      Vimond.HTTPClientMock
      |> expect(:put, fn "user",
                         body,
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8",
                           Authorization: "Bearer valid_authorization_token",
                           Cookie: "rememberMe=valid_remember_me"
                         ],
                         @config ->
        assert %{
                 "id" => 6_572_908,
                 "registrationDate" => 1_418_828_690_000,
                 "userName" => "some.person@example.com",
                 "email" => "some.person@example.com",
                 "emailStatus" => 2,
                 "firstName" => "Valid",
                 "lastName" => "User",
                 "zip" => "123 45",
                 "country" => "SWE",
                 "mobileNumber" => "0730236645",
                 "mobileStatus" => 0,
                 "dateOfBirth" => "1981-01-01",
                 "properties" => [
                   %{
                     "id" => 7_445_318,
                     "name" => "user_property_d",
                     "value" => "2016-06-17 09:26:17 UTC"
                   },
                   %{
                     "id" => 7_445_317,
                     "name" => "user_property_c",
                     "value" => "2016-05-20"
                   },
                   %{
                     "name" => "user_property_a",
                     "value" => "2018-09-02"
                   },
                   %{
                     "name" => "user_property_b",
                     "value" => "2015-09-02"
                   }
                 ]
               } == Jason.decode!(body)

        json = %{
          "address" => nil,
          "city" => nil,
          "confirmEmail" => nil,
          "country" => "SWE",
          "dateOfBirth" => "1981-01-01T00:00:00Z",
          "email" => "some.person@example.com",
          "emailStatus" => 2,
          "firstName" => "Valid",
          "gender" => nil,
          "id" => 6_572_908,
          "infoRestricted" => nil,
          "lastName" => "User",
          "mobileNumber" => "0730236645",
          "mobileStatus" => 0,
          "nick" => nil,
          "notifyUserOnCreation" => nil,
          "password" => nil,
          "properties" => [
            %{
              "id" => 7_445_318,
              "name" => "user_property_d",
              "value" => "2016-06-17 09:26:17 UTC"
            },
            %{
              "id" => 7_445_317,
              "name" => "user_property_c",
              "value" => "2016-05-20"
            },
            %{
              "id" => 7_445_319,
              "name" => "user_property_a",
              "value" => "2018-09-02"
            },
            %{
              "id" => 7_445_320,
              "name" => "user_property_b",
              "value" => "2015-09-02"
            }
          ],
          "receiveEmail" => nil,
          "receiveSms" => nil,
          "registrationDate" => 1_418_828_690_000,
          "state" => nil,
          "status" => nil,
          "uri" => "/api/platform/user/6572908",
          "userName" => "some.person@example.com",
          "userType" => nil,
          "zip" => "123 45"
        }

        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %{
            "content-type" => "application/json; v=3;charset=UTF-8",
            "authorization" => "Bearer valid_authorization_token"
          }
        }
      end)

      user = %Vimond.User{
        username: "some.person@example.com",
        first_name: "Valid",
        last_name: "User",
        zip_code: "123 45",
        country_code: "SWE",
        year_of_birth: 1981,
        properties: [
          %Vimond.Property{name: "user_property_a", value: "2018-09-02"},
          %Vimond.Property{name: "user_property_b", value: "2015-09-02"}
        ]
      }

      assert update("valid_authorization_token", "valid_remember_me", "6572908", user, @config) ==
               {:ok,
                %{
                  user: %Vimond.User{
                    user_id: "6572908",
                    username: "some.person@example.com",
                    email: "some.person@example.com",
                    first_name: "Valid",
                    last_name: "User",
                    zip_code: "123 45",
                    country_code: "SWE",
                    year_of_birth: 1981,
                    properties: [
                      %Vimond.Property{
                        id: 7_445_319,
                        name: "user_property_a",
                        value: "2018-09-02"
                      },
                      %Vimond.Property{
                        id: 7_445_320,
                        name: "user_property_b",
                        value: "2015-09-02"
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
                  session: %Vimond.Session{}
                }}
    end

    test "with invalid credentials" do
      user = %Vimond.User{username: "some.person@example.com", email: "some.person@example.com"}

      Vimond.HTTPClientMock
      |> expect(:get, fn _path, _headers, _config ->
        json = %{
          "error" => %{
            "code" => "SESSION_NOT_AUTHENTICATED",
            "description" => "User is not authenticated",
            "id" => "1044",
            "reference" => "47c53b2f78b812ee"
          }
        }

        %Vimond.Response{
          status_code: 401,
          body: Jason.encode!(json),
          headers: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8"
          }
        }
      end)

      assert update("invalid_vimond_authorization_token", "invalid_remember_me", "6572908", user, @config) ==
               {:error, %{type: :invalid_session, source_errors: ["User is not authenticated"]}}
    end

    test "with invalid response" do
      user = %Vimond.User{username: "some.person@example.com"}

      Vimond.HTTPClientMock
      |> expect(:get, fn _path, _headers, _config ->
        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(%{"userName" => "some_user@example.com"}),
          headers: %{
            "content-type" => "application/json; v=\"2\";charset=UTF-8",
            "authorization" => "Bearer valid_authorization_token"
          }
        }
      end)

      Vimond.HTTPClientMock
      |> expect(:put, fn _path, _body, _headers, _config ->
        %Vimond.Response{
          body:
            %{
              "error" => %{
                "code" => "UNKNOWN",
                "description" => "Unexpected error - look up reference in logfiles for more details.",
                "id" => "0",
                "reference" => "1ee10896d2cf17cd"
              }
            }
            |> Jason.encode!(),
          headers: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8"
          },
          status_code: 500
        }
      end)

      assert update("valid_vimond_authorization_token", "valid_remember_me", "6572908", user, @config) ==
               {:error, %{type: :generic, source_errors: ["Unexpected error"]}}
    end

    test "with email already registered response" do
      Vimond.HTTPClientMock
      |> expect(:get, fn _path, _headers, _config ->
        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(%{"userName" => "some_user@example.com"}),
          headers: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8",
            "authorization" => "Bearer valid_authorization_token"
          }
        }
      end)

      Vimond.HTTPClientMock
      |> expect(:put, fn _path, _body, _headers, _config ->
        %Vimond.Response{
          status_code: 400,
          body:
            Jason.encode!(%{
              "error" => %{
                "code" => "USER_INVALID_EMAIL",
                "description" => "Email address is already registered",
                "id" => "1026",
                "reference" => "7f6be90d2281dc21"
              }
            }),
          headers: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8",
            "authorization" => "Bearer valid_authorization_token"
          }
        }
      end)

      user = %Vimond.User{username: "some.person@example.com"}

      assert update("valid_vimond_athorization_token", "valid_remember_me", "6572908", user, @config) ==
               {:error, %{type: :email_already_in_use, source_errors: ["Email address is already registered"]}}
    end

    test "with invalid email" do
      Vimond.HTTPClientMock
      |> expect(:get, fn _path, _headers, _config ->
        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(%{"userName" => "some_user@example.com"}),
          headers: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8",
            "authorization" => "Bearer valid_authorization_token"
          }
        }
      end)

      Vimond.HTTPClientMock
      |> expect(:put, fn _path, _body, _headers, _config ->
        %Vimond.Response{
          status_code: 400,
          body:
            Jason.encode!(%{
              "error" => %{
                "code" => "USER_INVALID_EMAIL",
                "description" => "Cannot change email to invalid format",
                "id" => "1026",
                "reference" => "de175e7a0ee05cbf"
              }
            }),
          headers: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8"
          }
        }
      end)

      user = %Vimond.User{username: "some.person@example"}

      assert update("valid_vimond_athorization_token", "valid_remember_me", "6572908", user, @config) ==
               {:error, %{type: :email_invalid, source_errors: ["Cannot change email to invalid format"]}}
    end

    test "with username already registered response" do
      user = %Vimond.User{username: "some.person@example.com"}

      Vimond.HTTPClientMock
      |> expect(:get, fn _path, _headers, _config ->
        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(%{"userName" => "some_user@example.com"}),
          headers: %{
            "content-type" => "application/json; v=\"2\";charset=UTF-8"
          }
        }
      end)

      Vimond.HTTPClientMock
      |> expect(:put, fn _path, _body, _headers, _config ->
        %Vimond.Response{
          status_code: 400,
          body:
            Jason.encode!(%{
              "error" => %{
                "code" => "USER_INVALID_USERNAME",
                "description" => "Email address is already registered",
                "id" => "1024",
                "reference" => "00b5e4800b188126",
                "status" => nil
              }
            }),
          headers: %{
            "content-type" => "application/json; v=\"2\";charset=UTF-8"
          }
        }
      end)

      assert update("valid_vimond_authorization_token", "valid_remember_me", "6572908", user, @config) ==
               {:error, %{type: :username_already_in_use, source_errors: ["Email address is already registered"]}}
    end

    test "with renewed authorization token" do
      Vimond.HTTPClientMock
      |> expect(:get, fn _path,
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8",
                           Authorization: "Bearer expired_authorization_token",
                           Cookie: "rememberMe=valid_remember_me"
                         ],
                         @config ->
        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(%{"userName" => "some_user@example.com"}),
          headers: %{
            "content-type" => "application/json; v=\"2\";charset=UTF-8",
            "authorization" => "Bearer renewed_authorization_token"
          }
        }
      end)
      |> expect(:put, fn "user",
                         body,
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8",
                           Authorization: "Bearer renewed_authorization_token",
                           Cookie: "rememberMe=valid_remember_me"
                         ],
                         @config ->
        assert Jason.decode!(body) == %{
                 "id" => 6_572_908,
                 "userName" => "lodakai",
                 "email" => "some.person@example.com",
                 "properties" => []
               }

        %Vimond.Response{
          status_code: 200,
          body:
            Jason.encode!(%{
              "email" => "some.person@example.com",
              "id" => 6_572_908,
              "properties" => [],
              "userName" => "lodakai"
            }),
          headers: %{
            "content-type" => "application/json; v=\"2\";charset=UTF-8",
            "authorization" => "Bearer renewed_authorization_token"
          }
        }
      end)

      user = %Vimond.User{
        username: "lodakai",
        email: "some.person@example.com"
      }

      assert update("expired_authorization_token", "valid_remember_me", "6572908", user, @config) ==
               {:ok,
                %{
                  user: %Vimond.User{
                    user_id: "6572908",
                    username: "lodakai",
                    email: "some.person@example.com",
                    first_name: nil,
                    last_name: nil,
                    zip_code: nil,
                    country_code: nil,
                    year_of_birth: nil,
                    properties: []
                  },
                  session: %Vimond.Session{
                    vimond_authorization_token: "renewed_authorization_token"
                  }
                }}
    end

    test "do not update properties that the user are not allowed to update" do
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
          "address" => nil,
          "city" => nil,
          "confirmEmail" => nil,
          "country" => nil,
          "dateOfBirth" => "1981-01-01T00:00:00Z",
          "email" => "old@example.com",
          "emailStatus" => 2,
          "firstName" => "Valid",
          "gender" => nil,
          "id" => 6_572_908,
          "infoRestricted" => nil,
          "lastName" => "User",
          "mobileNumber" => "0730236645",
          "mobileStatus" => 0,
          "nick" => nil,
          "notifyUserOnCreation" => nil,
          "password" => nil,
          "properties" => [
            %{
              "hidden" => false,
              "id" => 7_445_317,
              "name" => "user_property_c",
              "uri" => nil,
              "userId" => 16_426_403,
              "value" => "2016-05-20"
            },
            %{
              "hidden" => false,
              "id" => 7_445_318,
              "allowUserToUpdate" => false,
              "name" => "isServiceOriginEUCitizen",
              "uri" => nil,
              "userId" => 16_426_403,
              "value" => "2016-06-17 09:26:17 UTC"
            }
          ],
          "receiveEmail" => nil,
          "receiveSms" => nil,
          "registrationDate" => 1_418_828_690_000,
          "state" => nil,
          "status" => nil,
          "uri" => "/api/platform/user/6572908",
          "userName" => "old@example.com",
          "userType" => nil,
          "zip" => "123 45"
        }

        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %{
            "content-type" => "application/json; v=3;charset=UTF-8",
            "authorization" => "Bearer valid_authorization_token"
          }
        }
      end)

      Vimond.HTTPClientMock
      |> expect(:put, fn "user",
                         body,
                         [
                           Accept: "application/json; v=3; charset=UTF-8",
                           "Content-Type": "application/json; v=3; charset=UTF-8",
                           Authorization: "Bearer valid_authorization_token",
                           Cookie: "rememberMe=valid_remember_me"
                         ],
                         @config ->
        assert %{
                 "id" => 6_572_908,
                 "registrationDate" => 1_418_828_690_000,
                 "userName" => "some.person@example.com",
                 "email" => "some.person@example.com",
                 "emailStatus" => 2,
                 "firstName" => "Valid",
                 "lastName" => "User",
                 "zip" => "123 45",
                 "country" => "SWE",
                 "mobileNumber" => "0730236645",
                 "mobileStatus" => 0,
                 "dateOfBirth" => "1981-01-01",
                 "properties" => [
                   %{
                     "id" => 7_445_317,
                     "name" => "user_property_c",
                     "value" => "2016-05-20"
                   },
                   %{
                     "name" => "user_property_a",
                     "value" => "2018-09-02"
                   },
                   %{
                     "name" => "user_property_b",
                     "value" => "2015-09-02"
                   }
                 ]
               } == Jason.decode!(body)

        json = %{
          "address" => nil,
          "city" => nil,
          "confirmEmail" => nil,
          "country" => "SWE",
          "dateOfBirth" => "1981-01-01T00:00:00Z",
          "email" => "some.person@example.com",
          "emailStatus" => 2,
          "firstName" => "Valid",
          "gender" => nil,
          "id" => 6_572_908,
          "infoRestricted" => nil,
          "lastName" => "User",
          "mobileNumber" => "0730236645",
          "mobileStatus" => 0,
          "nick" => nil,
          "notifyUserOnCreation" => nil,
          "password" => nil,
          "properties" => [
            %{
              "id" => 7_445_318,
              "name" => "isServiceOriginEUCitizen",
              "value" => "2016-06-17 09:26:17 UTC"
            },
            %{
              "id" => 7_445_317,
              "name" => "user_property_c",
              "value" => "2016-05-20"
            },
            %{
              "id" => 7_445_319,
              "name" => "user_property_a",
              "value" => "2018-09-02"
            },
            %{
              "id" => 7_445_320,
              "name" => "user_property_b",
              "value" => "2015-09-02"
            }
          ],
          "receiveEmail" => nil,
          "receiveSms" => nil,
          "registrationDate" => 1_418_828_690_000,
          "state" => nil,
          "status" => nil,
          "uri" => "/api/platform/user/6572908",
          "userName" => "some.person@example.com",
          "userType" => nil,
          "zip" => "123 45"
        }

        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %{
            "content-type" => "application/json; v=3;charset=UTF-8",
            "authorization" => "Bearer valid_authorization_token"
          }
        }
      end)

      user = %Vimond.User{
        username: "some.person@example.com",
        first_name: "Valid",
        last_name: "User",
        zip_code: "123 45",
        country_code: "SWE",
        year_of_birth: 1981,
        properties: [
          %Vimond.Property{name: "user_property_a", value: "2018-09-02"},
          %Vimond.Property{name: "user_property_b", value: "2015-09-02"}
        ]
      }

      assert update("valid_authorization_token", "valid_remember_me", "6572908", user, @config) ==
               {:ok,
                %{
                  user: %Vimond.User{
                    user_id: "6572908",
                    username: "some.person@example.com",
                    email: "some.person@example.com",
                    first_name: "Valid",
                    last_name: "User",
                    zip_code: "123 45",
                    country_code: "SWE",
                    year_of_birth: 1981,
                    properties: [
                      %Vimond.Property{
                        id: 7_445_318,
                        name: "isServiceOriginEUCitizen",
                        value: "2016-06-17 09:26:17 UTC"
                      },
                      %Vimond.Property{
                        id: 7_445_319,
                        name: "user_property_a",
                        value: "2018-09-02"
                      },
                      %Vimond.Property{
                        id: 7_445_320,
                        name: "user_property_b",
                        value: "2015-09-02"
                      },
                      %Vimond.Property{
                        id: 7_445_317,
                        name: "user_property_c",
                        value: "2016-05-20"
                      }
                    ]
                  },
                  session: %Vimond.Session{}
                }}
    end
  end

  describe "app authenticated" do
    test "when replacing a property and keeping a property" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "user/6572908",
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        json = %{
          "address" => nil,
          "city" => nil,
          "confirmEmail" => nil,
          "country" => nil,
          "dateOfBirth" => "1981-01-01T00:00:00Z",
          "email" => "old@example.com",
          "emailStatus" => 2,
          "firstName" => "Valid",
          "gender" => nil,
          "id" => 6_572_908,
          "infoRestricted" => nil,
          "lastName" => "User",
          "mobileNumber" => "0730236645",
          "mobileStatus" => 0,
          "nick" => nil,
          "notifyUserOnCreation" => nil,
          "password" => nil,
          "properties" => [],
          "receiveEmail" => nil,
          "receiveSms" => nil,
          "registrationDate" => 1_418_828_690_000,
          "state" => nil,
          "status" => nil,
          "uri" => "/api/platform/user/6572908",
          "userName" => "old@example.com",
          "userType" => nil,
          "zip" => "123 45"
        }

        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %{"content-type" => "application/json; v=3;charset=UTF-8"}
        }
      end)
      |> expect(:get_signed, fn "user/6572908/properties",
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        json = [
          %{
            "hidden" => false,
            "id" => 7_445_318,
            "name" => "user_property_d",
            "uri" => nil,
            "userId" => 16_426_403,
            "value" => "2016-06-17 09:26:17 UTC"
          },
          %{
            "hidden" => false,
            "id" => 7_445_317,
            "name" => "user_property_c",
            "uri" => nil,
            "userId" => 16_426_403,
            "value" => "2016-05-20"
          },
          %{
            "hidden" => false,
            "id" => 7_445_319,
            "name" => "user_property_a",
            "uri" => nil,
            "userId" => 16_426_403,
            "value" => "2018-05-25"
          },
          %{
            "hidden" => false,
            "id" => 7_445_320,
            "name" => "user_property_b",
            "uri" => nil,
            "userId" => 16_426_403,
            "value" => "2018-05-26 08:34:37 UTC"
          }
        ]

        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %{"content-type" => "application/json; v=3;charset=UTF-8"}
        }
      end)
      |> expect(:put_signed, fn "user",
                                body,
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        assert Jason.decode!(body) == %{
                 "id" => 6_572_908,
                 "registrationDate" => 1_418_828_690_000,
                 "userName" => "some.person@example.com",
                 "email" => "some.person@example.com",
                 "emailStatus" => 2,
                 "firstName" => "Valid",
                 "lastName" => "User",
                 "zip" => "123 45",
                 "country" => "SWE",
                 "mobileNumber" => "0730236645",
                 "mobileStatus" => 0,
                 "dateOfBirth" => "1981-01-01",
                 "properties" => [
                   %{
                     "id" => 7_445_318,
                     "name" => "user_property_d",
                     "value" => "2016-06-17 09:26:17 UTC"
                   },
                   %{
                     "id" => 7_445_317,
                     "name" => "user_property_c",
                     "value" => "2016-05-20"
                   },
                   %{
                     "id" => 7_445_319,
                     "name" => "user_property_a",
                     "value" => "2018-09-02"
                   },
                   %{
                     "id" => 7_445_320,
                     "name" => "user_property_b",
                     "value" => "2015-09-02"
                   }
                 ]
               }

        json = %{
          "address" => nil,
          "city" => nil,
          "confirmEmail" => nil,
          "country" => "SWE",
          "dateOfBirth" => "1981-01-01T00:00:00Z",
          "email" => "some.person@example.com",
          "emailStatus" => 2,
          "firstName" => "Valid",
          "gender" => nil,
          "id" => 6_572_908,
          "infoRestricted" => nil,
          "lastName" => "User",
          "mobileNumber" => "0730236645",
          "mobileStatus" => 0,
          "nick" => nil,
          "notifyUserOnCreation" => nil,
          "password" => nil,
          "properties" => [
            %{
              "id" => 7_445_318,
              "name" => "user_property_d",
              "value" => "2016-06-17 09:26:17 UTC"
            },
            %{
              "id" => 7_445_317,
              "name" => "user_property_c",
              "value" => "2016-05-20"
            },
            %{
              "id" => 7_445_319,
              "name" => "user_property_a",
              "value" => "2018-09-02"
            },
            %{
              "id" => 7_445_320,
              "name" => "user_property_b",
              "value" => "2015-09-02"
            }
          ],
          "receiveEmail" => nil,
          "receiveSms" => nil,
          "registrationDate" => 1_418_828_690_000,
          "state" => nil,
          "status" => nil,
          "uri" => "/api/platform/user/6572908",
          "userName" => "some.person@example.com",
          "userType" => nil,
          "zip" => "123 45"
        }

        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %{"content-type" => "application/json; v=3;charset=UTF-8"}
        }
      end)

      user = %Vimond.User{
        username: "some.person@example.com",
        first_name: "Valid",
        last_name: "User",
        zip_code: "123 45",
        country_code: "SWE",
        year_of_birth: 1981,
        properties: [
          %Vimond.Property{name: "user_property_a", value: "2018-09-02"},
          %Vimond.Property{name: "user_property_b", value: "2015-09-02"}
        ]
      }

      assert update_signed("6572908", user, @config) ==
               {:ok,
                %{
                  user: %Vimond.User{
                    user_id: "6572908",
                    username: "some.person@example.com",
                    email: "some.person@example.com",
                    first_name: "Valid",
                    last_name: "User",
                    zip_code: "123 45",
                    country_code: "SWE",
                    year_of_birth: 1981,
                    properties: [
                      %Vimond.Property{
                        id: 7_445_319,
                        name: "user_property_a",
                        value: "2018-09-02"
                      },
                      %Vimond.Property{
                        id: 7_445_320,
                        name: "user_property_b",
                        value: "2015-09-02"
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

    test "when adding a property and keeping a property" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "user/6572908",
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        json = %{
          "address" => nil,
          "city" => nil,
          "confirmEmail" => nil,
          "country" => nil,
          "dateOfBirth" => "1981-01-01T00:00:00Z",
          "email" => "old@example.com",
          "emailStatus" => 2,
          "firstName" => "Valid",
          "gender" => nil,
          "id" => 6_572_908,
          "infoRestricted" => nil,
          "lastName" => "User",
          "mobileNumber" => "0730236645",
          "mobileStatus" => 0,
          "nick" => nil,
          "notifyUserOnCreation" => nil,
          "password" => nil,
          "properties" => [],
          "receiveEmail" => nil,
          "receiveSms" => nil,
          "registrationDate" => 1_418_828_690_000,
          "state" => nil,
          "status" => nil,
          "uri" => "/api/platform/user/6572908",
          "userName" => "old@example.com",
          "userType" => nil,
          "zip" => "123 45"
        }

        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %{"content-type" => "application/json; v=3;charset=UTF-8"}
        }
      end)
      |> expect(:get_signed, fn "user/6572908/properties",
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
            "uri" => nil,
            "userId" => 16_426_403,
            "value" => "2016-05-20"
          },
          %{
            "hidden" => false,
            "id" => 7_445_318,
            "name" => "user_property_d",
            "uri" => nil,
            "userId" => 16_426_403,
            "value" => "2016-06-17 09:26:17 UTC"
          }
        ]

        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %{"content-type" => "application/json; v=3;charset=UTF-8"}
        }
      end)
      |> expect(:put_signed, fn "user",
                                body,
                                [
                                  Accept: "application/json; v=3; charset=UTF-8",
                                  "Content-Type": "application/json; v=3; charset=UTF-8"
                                ],
                                @config ->
        assert %{
                 "id" => 6_572_908,
                 "registrationDate" => 1_418_828_690_000,
                 "userName" => "some.person@example.com",
                 "email" => "some.person@example.com",
                 "emailStatus" => 2,
                 "firstName" => "Valid",
                 "lastName" => "User",
                 "zip" => "123 45",
                 "country" => "SWE",
                 "mobileNumber" => "0730236645",
                 "mobileStatus" => 0,
                 "dateOfBirth" => "1981-01-01",
                 "properties" => [
                   %{
                     "id" => 7_445_318,
                     "name" => "user_property_d",
                     "value" => "2016-06-17 09:26:17 UTC"
                   },
                   %{
                     "id" => 7_445_317,
                     "name" => "user_property_c",
                     "value" => "2016-05-20"
                   },
                   %{
                     "name" => "user_property_a",
                     "value" => "2018-09-02"
                   },
                   %{
                     "name" => "user_property_b",
                     "value" => "2015-09-02"
                   }
                 ]
               } == Jason.decode!(body)

        json = %{
          "address" => nil,
          "city" => nil,
          "confirmEmail" => nil,
          "country" => "SWE",
          "dateOfBirth" => "1981-01-01T00:00:00Z",
          "email" => "some.person@example.com",
          "emailStatus" => 2,
          "firstName" => "Valid",
          "gender" => nil,
          "id" => 6_572_908,
          "infoRestricted" => nil,
          "lastName" => "User",
          "mobileNumber" => "0730236645",
          "mobileStatus" => 0,
          "nick" => nil,
          "notifyUserOnCreation" => nil,
          "password" => nil,
          "properties" => [
            %{
              "id" => 7_445_318,
              "name" => "user_property_d",
              "value" => "2016-06-17 09:26:17 UTC"
            },
            %{
              "id" => 7_445_317,
              "name" => "user_property_c",
              "value" => "2016-05-20"
            },
            %{
              "id" => 7_445_319,
              "name" => "user_property_a",
              "value" => "2018-09-02"
            },
            %{
              "id" => 7_445_320,
              "name" => "user_property_b",
              "value" => "2015-09-02"
            }
          ],
          "receiveEmail" => nil,
          "receiveSms" => nil,
          "registrationDate" => 1_418_828_690_000,
          "state" => nil,
          "status" => nil,
          "uri" => "/api/platform/user/6572908",
          "userName" => "some.person@example.com",
          "userType" => nil,
          "zip" => "123 45"
        }

        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(json),
          headers: %{"content-type" => "application/json; v=3;charset=UTF-8"}
        }
      end)

      user = %Vimond.User{
        username: "some.person@example.com",
        first_name: "Valid",
        last_name: "User",
        zip_code: "123 45",
        country_code: "SWE",
        year_of_birth: 1981,
        properties: [
          %Vimond.Property{name: "user_property_a", value: "2018-09-02"},
          %Vimond.Property{name: "user_property_b", value: "2015-09-02"}
        ]
      }

      assert update_signed("6572908", user, @config) ==
               {:ok,
                %{
                  user: %Vimond.User{
                    user_id: "6572908",
                    username: "some.person@example.com",
                    email: "some.person@example.com",
                    first_name: "Valid",
                    last_name: "User",
                    zip_code: "123 45",
                    country_code: "SWE",
                    year_of_birth: 1981,
                    properties: [
                      %Vimond.Property{
                        id: 7_445_319,
                        name: "user_property_a",
                        value: "2018-09-02"
                      },
                      %Vimond.Property{
                        id: 7_445_320,
                        name: "user_property_b",
                        value: "2015-09-02"
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

    test "when user does not exist" do
      user = %Vimond.User{username: "some.person@example.com", email: "some.person@example.com"}

      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "user/6572908", _headers, _config ->
        json = %{
          "error" => %{
            "code" => "USER_NOT_FOUND",
            "description" => nil,
            "id" => "1023",
            "reference" => "c69ab081d6bcebe1"
          }
        }

        %Vimond.Response{
          status_code: 401,
          body: Jason.encode!(json),
          headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
        }
      end)

      assert update_signed("6572908", user, @config) == {:error, %{type: :user_not_found, source_errors: [nil]}}
    end

    test "with invalid response" do
      user = %Vimond.User{username: "some.person@example.com"}

      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "user/6572908", _headers, _config ->
        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(%{"userName" => "some_user@example.com"}),
          headers: %{"content-type" => "application/json; v=\"2\";charset=UTF-8"}
        }
      end)
      |> expect(:get_signed, fn "user/6572908/properties", _headers, _config ->
        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!([]),
          headers: %{"content-type" => "application/json; v=\"2\";charset=UTF-8"}
        }
      end)
      |> expect(:put_signed, fn "user", _body, _headers, _config ->
        %Vimond.Response{
          body:
            %{
              "error" => %{
                "code" => "UNKNOWN",
                "description" => "Unexpected error - look up reference in logfiles for more details.",
                "id" => "0",
                "reference" => "1ee10896d2cf17cd"
              }
            }
            |> Jason.encode!(),
          headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"},
          status_code: 500
        }
      end)

      assert update_signed("6572908", user, @config) == {:error, %{type: :generic, source_errors: ["Unexpected error"]}}
    end

    test "with email already registered response" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "user/6572908", _headers, _config ->
        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(%{"userName" => "some_user@example.com"}),
          headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
        }
      end)
      |> expect(:get_signed, fn "user/6572908/properties", _headers, _config ->
        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!([]),
          headers: %{"content-type" => "application/json; v=\"2\";charset=UTF-8"}
        }
      end)
      |> expect(:put_signed, fn "user", _body, _headers, _config ->
        %Vimond.Response{
          status_code: 400,
          body:
            Jason.encode!(%{
              "error" => %{
                "code" => "USER_INVALID_EMAIL",
                "description" => "Email address is already registered",
                "id" => "1026",
                "reference" => "7f6be90d2281dc21"
              }
            }),
          headers: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8",
            "authorization" => "Bearer valid_authorization_token"
          }
        }
      end)

      user = %Vimond.User{username: "some.person@example.com"}

      assert update_signed("6572908", user, @config) ==
               {:error, %{type: :email_already_in_use, source_errors: ["Email address is already registered"]}}
    end

    test "with invalid email" do
      Vimond.HTTPClientMock
      |> expect(:get_signed, fn "user/6572908", _headers, _config ->
        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!(%{"userName" => "some_user@example.com"}),
          headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
        }
      end)
      |> expect(:get_signed, fn "user/6572908/properties", _headers, _config ->
        %Vimond.Response{
          status_code: 200,
          body: Jason.encode!([]),
          headers: %{"content-type" => "application/json; v=\"2\";charset=UTF-8"}
        }
      end)
      |> expect(:put_signed, fn "user", _body, _headers, _config ->
        %Vimond.Response{
          status_code: 400,
          body:
            Jason.encode!(%{
              "error" => %{
                "code" => "USER_INVALID_EMAIL",
                "description" => "Cannot change email to invalid format",
                "id" => "1026",
                "reference" => "de175e7a0ee05cbf"
              }
            }),
          headers: %{
            "content-type" => "application/json; v=\"3\";charset=UTF-8"
          }
        }
      end)

      user = %Vimond.User{username: "some.person@example"}

      assert update_signed("6572908", user, @config) ==
               {:error, %{type: :email_invalid, source_errors: ["Cannot change email to invalid format"]}}
    end

    test "with username already registered response" do
      user = %Vimond.User{username: "some.person@example.com"}

      Vimond.HTTPClientMock
      |> expect(:get_signed, 2, fn path, _headers, _config ->
        case path do
          "user/6572908" ->
            %Vimond.Response{
              status_code: 200,
              body: Jason.encode!(%{"userName" => "some_user@example.com"}),
              headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
            }

          "user/6572908/properties" ->
            %Vimond.Response{
              status_code: 200,
              body: Jason.encode!([]),
              headers: %{"content-type" => "application/json; v=\"2\";charset=UTF-8"}
            }
        end
      end)
      |> expect(:put_signed, fn "user", _body, _headers, _config ->
        %Vimond.Response{
          status_code: 400,
          body:
            Jason.encode!(%{
              "error" => %{
                "code" => "USER_INVALID_USERNAME",
                "description" => "Email address is already registered",
                "id" => "1024",
                "reference" => "00b5e4800b188126",
                "status" => nil
              }
            }),
          headers: %{"content-type" => "application/json; v=\"2\";charset=UTF-8"}
        }
      end)

      assert update_signed("6572908", user, @config) ==
               {:error, %{type: :username_already_in_use, source_errors: ["Email address is already registered"]}}
    end
  end
end
