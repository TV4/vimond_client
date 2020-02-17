defmodule Vimond.AssetTest do
  use ExUnit.Case
  import Mox
  alias Vimond.{Asset, Client}

  setup :verify_on_exit!

  @config %Vimond.Config{
    base_url: "https://vimond-rest-api.example.com/api/tv4/",
    api_key: "key",
    api_secret: "secret"
  }

  test "get asset" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "asset/10002224/productgroups",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %Vimond.Response{
        status_code: 200,
        body:
          %{
            "productGroups" => [
              %{
                "accessType" => "PAID",
                "categoriesUri" => %{"uri" => "/api/cse/productgroup/1009/categories"},
                "checkAccessForProgramRelations" => false,
                "description" => "C More All sport",
                "id" => 1009,
                "metadata" => %{
                  "empty" => false,
                  "entries" => %{
                    "productgroup-slug" => [%{"lang" => "*", "value" => "c-more-max"}]
                  },
                  "uri" => "/api/metadata/productgroup/1009"
                },
                "name" => "C More All sport",
                "productGroupAccessesUri" => %{},
                "productsUri" => %{
                  "products" => [],
                  "uri" => "/api/cse/productgroup/1009/products"
                },
                "saleStatus" => "ENABLED",
                "sortIndex" => 3,
                "uri" => "/api/cse/productgroup/1009"
              },
              %{
                "accessType" => "PAID",
                "categoriesUri" => %{"uri" => "/api/cse/productgroup/1017/categories"},
                "checkAccessForProgramRelations" => false,
                "description" => "Matchbiljett",
                "id" => 1017,
                "metadata" => %{
                  "empty" => false,
                  "entries" => %{
                    "productgroup-slug" => [%{"lang" => "*", "value" => "ppv-premium"}]
                  },
                  "uri" => "/api/metadata/productgroup/1017"
                },
                "name" => "Matchbiljett 249 kr",
                "productGroupAccessesUri" => %{},
                "productsUri" => %{
                  "products" => [],
                  "uri" => "/api/cse/productgroup/1017/products"
                },
                "saleStatus" => "ENABLED",
                "sortIndex" => 3,
                "uri" => "/api/cse/productgroup/1017"
              },
              %{
                "accessType" => "PAID",
                "categoriesUri" => %{"uri" => "/api/cse/productgroup/1243/categories"},
                "checkAccessForProgramRelations" => false,
                "description" => "C More All sport årspaket",
                "id" => 1243,
                "metadata" => %{
                  "empty" => false,
                  "entries" => %{
                    "productgroup-slug" => [%{"lang" => "*", "value" => "premium-year"}]
                  },
                  "uri" => "/api/metadata/productgroup/1243"
                },
                "name" => "C More All sport årspaket",
                "productGroupAccessesUri" => %{},
                "productsUri" => %{
                  "products" => [],
                  "uri" => "/api/cse/productgroup/1243/products"
                },
                "saleStatus" => "ENABLED",
                "sortIndex" => 4,
                "uri" => "/api/cse/productgroup/1243"
              },
              %{
                "accessType" => "PAID",
                "categoriesUri" => %{"uri" => "/api/cse/productgroup/1008/categories"},
                "checkAccessForProgramRelations" => false,
                "description" => "C More Sport SE",
                "id" => 1008,
                "metadata" => %{
                  "empty" => false,
                  "entries" => %{
                    "productgroup-customconf" => [
                      %{
                        "lang" => "*",
                        "value" =>
                          "{\n     \"theme\": \"sea-green\",\n     \"full_access\": false,\n     \"signup\": {\n        \"text\": \"Beställ nu\",\n        \"link\": null\n     },\n     \"pricing\": null,\n     \"sidebar\": {\n       \"subheading\": \"Det här ingår\",\n       \"highlights\": [\"Allsvenskan\", \"SHL\", \"Superettan\", \"La Liga\", \"Serie A\"]\n     }\n   }"
                      }
                    ],
                    "productgroup-description" => [
                      %{
                        "lang" => "*",
                        "value" =>
                          "Se de bästa och mest nervkittlande matcherna från Allsvenskan SHL, Superettan, La Liga och Serie A"
                      }
                    ],
                    "productgroup-slug" => [%{"lang" => "*", "value" => "c-more-sport"}],
                    "productgroup-title" => [%{"lang" => "*", "value" => "Sport"}]
                  },
                  "uri" => "/api/metadata/productgroup/1008"
                },
                "name" => "C More Sport SE",
                "productGroupAccessesUri" => %{},
                "productsUri" => %{
                  "products" => [],
                  "uri" => "/api/cse/productgroup/1008/products"
                },
                "saleStatus" => "ENABLED",
                "sortIndex" => 10,
                "uri" => "/api/cse/productgroup/1008"
              }
            ]
          }
          |> Jason.encode!()
      }
    end)

    assert Client.asset("10002224", @config) == {:ok, %Asset{product_group_ids: [1009, 1017, 1243, 1008]}}
  end

  test "asset not found" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "asset/10002224/productgroups",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %Vimond.Response{
        body:
          %{
            "error" => %{
              "code" => "ASSET_NOT_FOUND",
              "description" => "Asset with id '10002224' was not found",
              "id" => "1055",
              "reference" => "9cc849847f7bebef"
            }
          }
          |> Jason.encode!(),
        status_code: 404
      }
    end)

    assert Client.asset("10002224", @config) ==
             {:error, %{type: :asset_not_found, source_errors: ["Asset with id '10002224' was not found"]}}
  end

  test "asset not published" do
    Vimond.HTTPClientMock
    |> expect(:get, fn "asset/10002224/productgroups",
                       [
                         Accept: "application/json; v=3; charset=UTF-8",
                         "Content-Type": "application/json; v=3; charset=UTF-8"
                       ],
                       @config ->
      %Vimond.Response{
        body:
          %{
            "error" => %{
              "code" => "ASSET_NOT_PUBLISHED",
              "description" => "Asset is not published on platform 'cmore-se'",
              "id" => "1058",
              "reference" => "42f48086937017a2"
            }
          }
          |> Jason.encode!(),
        status_code: 404
      }
    end)

    assert Client.asset("10002224", @config) ==
             {:error, %{type: :asset_not_published, source_errors: ["Asset is not published on platform 'cmore-se'"]}}
  end
end
