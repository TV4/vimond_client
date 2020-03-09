defmodule Vimond.Client.CreateTest do
  use ExUnit.Case, async: true
  alias Vimond.Config
  import Vimond.Client
  import Hammox

  setup :verify_on_exit!

  @config %Config{base_url: "https://vimond-rest-api.example.com/api/platform/"}

  test "returns the user when a user was created" do
    Vimond.HTTPClientMock
    |> expect(:post, fn "user",
                        body,
                        [
                          Accept: "application/json; v=3; charset=UTF-8",
                          "Content-Type": "application/json; v=3; charset=UTF-8"
                        ],
                        @config ->
      assert Jason.decode!(body) == %{
               "userName" => "new_user",
               "password" => "password",
               "email" => "new_user@host.com",
               "firstName" => "New",
               "lastName" => "User",
               "zip" => "123 45",
               "country" => "SWE",
               "dateOfBirth" => "1977-01-01",
               "properties" => [
                 %{"name" => "user_property_c", "value" => "2018-05-25"},
                 %{"name" => "user_property_d", "value" => "2015-09-02"}
               ]
             }

      %Vimond.Response{
        status_code: 200,
        body:
          %{
            "country" => "SWE",
            "dateOfBirth" => "1977-01-01T00:00:00Z",
            "email" => "new_user@host.com",
            "emailStatus" => 2,
            "firstName" => "New",
            "id" => 12_345_678,
            "lastName" => "User",
            "mobileNumber" => "0712345678",
            "mobileStatus" => 0,
            "properties" => [
              %{
                "allowUserToUpdate" => true,
                "hidden" => false,
                "id" => 50_002_611,
                "name" => "user_property_c",
                "userId" => 1_000_066_284,
                "value" => "2018-05-25"
              },
              %{
                "allowUserToUpdate" => true,
                "hidden" => false,
                "id" => 50_002_612,
                "name" => "user_property_d",
                "userId" => 1_000_066_284,
                "value" => "2015-09-02"
              }
            ],
            "registrationDate" => "2015-09-02T13:24:35Z",
            "userName" => "new_user",
            "zip" => "123 45"
          }
          |> Jason.encode!(),
        headers: %{"content-type" => "application/json; v=3;charset=UTF-8"}
      }
    end)

    user = %Vimond.User{
      username: "new_user",
      password: "password",
      email: "new_user@host.com",
      first_name: "New",
      last_name: "User",
      zip_code: "123 45",
      country_code: "SWE",
      year_of_birth: 1977,
      properties: [
        %Vimond.Property{name: "user_property_c", value: "2018-05-25"},
        %Vimond.Property{name: "user_property_d", value: "2015-09-02"}
      ]
    }

    assert create(user, @config) ==
             {:ok,
              %{
                user: %Vimond.User{
                  user_id: "12345678",
                  username: "new_user",
                  email: "new_user@host.com",
                  first_name: "New",
                  last_name: "User",
                  zip_code: "123 45",
                  country_code: "SWE",
                  year_of_birth: 1977,
                  properties: [
                    %Vimond.Property{
                      allow_user_to_update: true,
                      id: 50_002_611,
                      name: "user_property_c",
                      value: "2018-05-25"
                    },
                    %Vimond.Property{
                      allow_user_to_update: true,
                      id: 50_002_612,
                      name: "user_property_d",
                      value: "2015-09-02"
                    }
                  ]
                }
              }}
  end

  test "returns an error when the user already exists in Vimond" do
    Vimond.HTTPClientMock
    |> expect(:post, fn _path, _body, _headers, _config ->
      %Vimond.Response{
        status_code: 400,
        body:
          %{
            "error" => %{
              "code" => "USER_MULTIPLE_VALIDATION_ERRORS",
              "description" => nil,
              "errors" => [
                %{
                  "code" => "USER_INVALID_EMAIL",
                  "description" => "Email address is already registered",
                  "id" => 1026,
                  "reference" => "7eb7764fd11febe4"
                },
                %{
                  "code" => "USER_INVALID_USERNAME",
                  "description" => "Username is already registered",
                  "id" => 1024,
                  "reference" => "9b6edb39888a9015"
                }
              ],
              "id" => "1032",
              "reference" => "c3bf0b56b8ca2169"
            }
          }
          |> Jason.encode!(),
        headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
      }
    end)

    user = %Vimond.User{
      username: "existing_user",
      email: "existing_user@host.com",
      password: "password",
      first_name: "New",
      last_name: "User",
      year_of_birth: 1977,
      zip_code: "123 45"
    }

    assert create(user, @config) ==
             {:error,
              %{
                type: :username_already_in_use,
                source_errors: [
                  "Email address is already registered",
                  "Username is already registered"
                ]
              }}
  end

  test "returns an error when the users email exists in Vimond" do
    Vimond.HTTPClientMock
    |> expect(:post, fn _path, _body, _headers, _config ->
      %Vimond.Response{
        status_code: 400,
        body:
          %{
            "error" => %{
              "code" => "USER_MULTIPLE_VALIDATION_ERRORS",
              "description" => nil,
              "errors" => [
                %{
                  "code" => "USER_INVALID_EMAIL",
                  "description" => "Email address is already registered",
                  "id" => 1026,
                  "reference" => "7eb7764fd11febe4"
                }
              ],
              "id" => "1032",
              "reference" => "c3bf0b56b8ca2169"
            }
          }
          |> Jason.encode!(),
        headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
      }
    end)

    user = %Vimond.User{
      username: "existing_user",
      email: "existing_user@host.com",
      password: "password",
      first_name: "New",
      last_name: "User",
      year_of_birth: 1977,
      zip_code: "123 45"
    }

    assert create(user, @config) ==
             {:error,
              %{
                type: :email_already_in_use,
                source_errors: ["Email address is already registered"]
              }}
  end

  test "returns an error when the users email is invalid in Vimond" do
    Vimond.HTTPClientMock
    |> expect(:post, fn _path, _body, _headers, _config ->
      %Vimond.Response{
        status_code: 400,
        body:
          %{
            "error" => %{
              "code" => "USER_MULTIPLE_VALIDATION_ERRORS",
              "description" => nil,
              "errors" => [
                %{
                  "code" => "USER_INVALID_EMAIL",
                  "description" => "Email address is not valid",
                  "id" => 1026,
                  "reference" => "448669d5cc93696f"
                }
              ],
              "id" => "1032",
              "reference" => "5f7f694ec11a00aa"
            }
          }
          |> Jason.encode!(),
        headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
      }
    end)

    user = %Vimond.User{
      username: "invalid",
      email: "invalid@email..com",
      password: "password",
      first_name: "New",
      last_name: "User",
      year_of_birth: 1977,
      zip_code: "123 45"
    }

    assert create(user, @config) ==
             {:error, %{type: :email_invalid, source_errors: ["Email address is not valid"]}}
  end

  test "returns an error when there is an unknown USER_MULTIPLE_VALIDATION_ERRORS type" do
    Vimond.HTTPClientMock
    |> expect(:post, fn _path, _body, _headers, _config ->
      %Vimond.Response{
        status_code: 400,
        body:
          %{
            "error" => %{
              "code" => "USER_MULTIPLE_VALIDATION_ERRORS",
              "description" => nil,
              "errors" => [
                %{
                  "code" => "THE_NUMBER_OF_THE_BEAST",
                  "description" => "Beast mode",
                  "id" => 666,
                  "reference" => "448669d5cc93696f"
                },
                %{
                  "code" => "THE_NUMBER_OF_THE_LITTLE_BEAST",
                  "description" => "Some kind of monster",
                  "id" => 66,
                  "reference" => "448669d5cc93696f"
                }
              ],
              "id" => "1032",
              "reference" => "5f7f694ec11a00aa"
            }
          }
          |> Jason.encode!(),
        headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
      }
    end)

    user = %Vimond.User{
      username: "unknown_error",
      password: "password",
      first_name: "New",
      last_name: "User",
      year_of_birth: 1977,
      zip_code: "123 45"
    }

    assert create(user, @config) ==
             {:error,
              %{
                type: :user_creation_failed,
                source_errors: ["Beast mode", "Some kind of monster"]
              }}
  end

  test "with an unknown error code" do
    Vimond.HTTPClientMock
    |> expect(:post, fn _path, _body, _headers, _config ->
      %Vimond.Response{
        status_code: 400,
        body:
          %{
            "error" => %{
              "code" => "THE_NUMBER_OF_THE_BEAST",
              "description" => nil,
              "id" => "666",
              "reference" => "5f7f694ec11a00aa"
            }
          }
          |> Jason.encode!(),
        headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
      }
    end)

    user = %Vimond.User{
      username: "unknown_error",
      password: "password",
      first_name: "New",
      last_name: "User",
      year_of_birth: 1977,
      zip_code: "123 45"
    }

    assert create(user, @config) ==
             {:error, %{type: :user_creation_failed, source_errors: ["THE_NUMBER_OF_THE_BEAST"]}}
  end

  test "with an unknown response" do
    Vimond.HTTPClientMock
    |> expect(:post, fn _path, _body, _headers, _config ->
      %Vimond.Response{
        status_code: 400,
        body: Jason.encode!(%{"hello" => "world"}),
        headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
      }
    end)

    user = %Vimond.User{
      username: "unknown_response",
      password: "password",
      first_name: "New",
      last_name: "User",
      year_of_birth: 1977,
      zip_code: "123 45"
    }

    assert create(user, @config) ==
             {:error, %{type: :generic, source_errors: ["Unexpected error"]}}
  end
end
