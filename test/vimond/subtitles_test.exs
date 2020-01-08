defmodule Vimond.SubtitlesTest do
  use ExUnit.Case
  import Mox
  alias Vimond.{Client, Subtitle}

  setup :verify_on_exit!

  @config %Vimond.Config{
    base_url: "https://vimond-rest-api.example.com/api/tv4/",
    api_key: "key",
    api_secret: "secret"
  }

  test "get subtitle" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "asset/10002224/subtitles",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %HTTPotion.Response{
        status_code: 200,
        body:
          [
            %{
              "assetId" => 10_002_224,
              "contentType" => "text/vtt;charset=\"UTF-8\"",
              "id" => 77582,
              "locale" => "swe",
              "name" => "swe",
              "type" => "NORMAL",
              "uri" => "/api/tv4/asset/10002224/subtitle/77582"
            }
          ]
          |> Jason.encode!(),
        headers: %HTTPotion.Headers{
          hdrs: %{
            "content-type" => "application/json; v=3;charset=UTF-8"
          }
        }
      }
    end)

    assert Client.subtitles("10002224", @config) ==
             {:ok,
              [
                %Subtitle{
                  asset_id: 10_002_224,
                  content_type: "text/vtt;charset=\"UTF-8\"",
                  id: 77582,
                  locale: "swe",
                  name: "swe",
                  type: "NORMAL",
                  uri: "/api/tv4/asset/10002224/subtitle/77582"
                }
              ]}
  end
end
