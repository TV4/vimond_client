defmodule Vimond.Client.SetPropertyTest do
  use ExUnit.Case
  alias Vimond.{Config, Property}
  import Vimond.Client
  import Hammox

  setup :verify_on_exit!

  @config %Config{
    base_url: "https://vimond-rest-api.example.com/api/platform/",
    api_key: "key",
    api_secret: "secret"
  }

  test "when there is no property" do
    Vimond.HTTPClientMock
    |> expect(:get_signed, fn "user/16368984/properties",
                              [
                                Accept: "application/json; v=3; charset=UTF-8",
                                "Content-Type": "application/json; v=3; charset=UTF-8"
                              ],
                              @config ->
      %Vimond.Response{
        body:
          [
            %{
              "allowUserToUpdate" => true,
              "hidden" => false,
              "id" => 6_115_947,
              "name" => "accepted_play_terms_date",
              "uri" => "/api/web/user/16368984/property/6115947",
              "value" => "2016-01-12 12:02:56 UTC"
            },
            %{
              "allowUserToUpdate" => true,
              "hidden" => false,
              "id" => 6_015_612,
              "name" => "accepted_play_terms",
              "uri" => "/api/web/user/16368984/property/6015612",
              "value" => "2013-11-13"
            }
          ]
          |> Jason.encode!(),
        status_code: 200
      }
    end)
    |> expect(:post_signed, fn "user/16368984/property",
                               body,
                               [
                                 Accept: "application/json; v=3; charset=UTF-8",
                                 "Content-Type": "application/json; v=3; charset=UTF-8"
                               ],
                               @config ->
      assert %{
               "allowUserToUpdate" => false,
               "name" => "isServiceOriginEUCitizen",
               "value" => true
             } == Jason.decode!(body)

      %Vimond.Response{
        body:
          %{
            "allowUserToUpdate" => false,
            "hidden" => false,
            "id" => 50_019_330,
            "name" => "isServiceOriginEUCitizen",
            "uri" => "/api/web/user/16368984/property/50019330",
            "value" => "true"
          }
          |> Jason.encode!(),
        status_code: 200
      }
    end)

    property = %Property{
      name: "isServiceOriginEUCitizen",
      value: true,
      allow_user_to_update: false
    }

    assert set_property_signed("16368984", property, @config) == :ok
  end

  test "when there is one property" do
    Vimond.HTTPClientMock
    |> expect(:get_signed, fn "user/16368984/properties",
                              [
                                Accept: "application/json; v=3; charset=UTF-8",
                                "Content-Type": "application/json; v=3; charset=UTF-8"
                              ],
                              @config ->
      %Vimond.Response{
        body:
          [
            %{
              "allowUserToUpdate" => true,
              "hidden" => false,
              "id" => 6_115_947,
              "name" => "accepted_play_terms_date",
              "uri" => "/api/web/user/16368984/property/6115947",
              "value" => "2016-01-12 12:02:56 UTC"
            },
            %{
              "allowUserToUpdate" => true,
              "hidden" => false,
              "id" => 6_015_612,
              "name" => "accepted_play_terms",
              "uri" => "/api/web/user/16368984/property/6015612",
              "value" => "2013-11-13"
            },
            %{
              "allowUserToUpdate" => false,
              "hidden" => false,
              "id" => 50_019_330,
              "name" => "isServiceOriginEUCitizen",
              "uri" => "/api/web/user/16368984/property/50019330",
              "value" => "true"
            }
          ]
          |> Jason.encode!(),
        status_code: 200
      }
    end)
    |> expect(:put_signed, fn "user/16368984/property/50019330",
                              body,
                              [
                                Accept: "application/json; v=3; charset=UTF-8",
                                "Content-Type": "application/json; v=3; charset=UTF-8"
                              ],
                              @config ->
      assert %{
               "allowUserToUpdate" => false,
               "id" => 50_019_330,
               "name" => "isServiceOriginEUCitizen",
               "value" => false
             } == Jason.decode!(body)

      %Vimond.Response{
        body:
          %{
            "allowUserToUpdate" => false,
            "hidden" => false,
            "id" => 50_019_330,
            "name" => "isServiceOriginEUCitizen",
            "uri" => "/api/web/user/16368984/property/50019330",
            "value" => "false"
          }
          |> Jason.encode!(),
        status_code: 200
      }
    end)

    property = %Property{
      name: "isServiceOriginEUCitizen",
      value: false,
      allow_user_to_update: false
    }

    assert set_property_signed("16368984", property, @config) == :ok
  end

  test "when there are multiple properties" do
    Vimond.HTTPClientMock
    |> expect(:get_signed, fn "user/16368984/properties",
                              [
                                Accept: "application/json; v=3; charset=UTF-8",
                                "Content-Type": "application/json; v=3; charset=UTF-8"
                              ],
                              @config ->
      %Vimond.Response{
        body:
          [
            %{
              "allowUserToUpdate" => true,
              "hidden" => false,
              "id" => 6_115_947,
              "name" => "accepted_play_terms_date",
              "uri" => "/api/web/user/16368984/property/6115947",
              "value" => "2016-01-12 12:02:56 UTC"
            },
            %{
              "allowUserToUpdate" => true,
              "hidden" => false,
              "id" => 6_015_612,
              "name" => "accepted_play_terms",
              "uri" => "/api/web/user/16368984/property/6015612",
              "value" => "2013-11-13"
            },
            %{
              "allowUserToUpdate" => false,
              "hidden" => false,
              "id" => 50_019_330,
              "name" => "isServiceOriginEUCitizen",
              "uri" => "/api/web/user/16368984/property/50019330",
              "value" => true
            },
            %{
              "allowUserToUpdate" => false,
              "hidden" => false,
              "id" => 50_019_331,
              "name" => "isServiceOriginEUCitizen",
              "uri" => "/api/web/user/16368984/property/50019331",
              "value" => false
            }
          ]
          |> Jason.encode!(),
        status_code: 200
      }
    end)
    |> expect(:put_signed, fn "user/16368984/property/50019331",
                              body,
                              [
                                Accept: "application/json; v=3; charset=UTF-8",
                                "Content-Type": "application/json; v=3; charset=UTF-8"
                              ],
                              @config ->
      assert %{
               "allowUserToUpdate" => false,
               "id" => 50_019_331,
               "name" => "isServiceOriginEUCitizen",
               "value" => true
             } == Jason.decode!(body)

      %Vimond.Response{
        body:
          %{
            "allowUserToUpdate" => false,
            "hidden" => false,
            "id" => 50_019_331,
            "name" => "isServiceOriginEUCitizen",
            "uri" => "/api/web/user/16368984/property/50019331",
            "value" => "true"
          }
          |> Jason.encode!(),
        status_code: 200
      }
    end)

    property = %Property{
      name: "isServiceOriginEUCitizen",
      value: true,
      allow_user_to_update: false
    }

    assert set_property_signed("16368984", property, @config) == :ok
  end
end
