defmodule Vimond.HTTPClientTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  @config %Vimond.Config{
    api_key: "key",
    api_secret: "secret",
    base_url: "https://vimond-rest-api.example.com/api/platförm/"
  }

  test "delete" do
    HTTPClientMock
    |> expect(
      :request,
      fn :delete,
         "https://vimond-rest-api.example.com/api/platf%C3%B6rm/delete/p%C3%A4th",
         [{"Accept", "text/plain"}],
         "",
         timeout: _ ->
        {:error, %Mojito.Error{message: "oh noes!"}}
      end
    )

    assert Vimond.HTTPClient.delete("delete/päth", [Accept: "text/plain"], @config) == %Vimond.Error{
             message: "oh noes!"
           }
  end

  test "delete_signed" do
    HTTPClientMock
    |> expect(
      :request,
      fn :delete,
         "https://vimond-rest-api.example.com/api/platf%C3%B6rm/delete_signed/p%C3%A4th",
         [
           {"Authorization", "SUMO key:2m4KdoMUScnkGqcqeMjhD+eC9LM="},
           {"Date", "Wed, 02 Sep 2015 13:24:35 +0000"},
           {"Accept", "text/plain"}
         ],
         "",
         timeout: _ ->
        {:ok,
         %Mojito.Response{
           body: "",
           headers: [
             {"authorization", "Bearer abc123"},
             {"authorization", "Bearer def456"}
           ],
           status_code: 204
         }}
      end
    )

    assert Vimond.HTTPClient.delete_signed("delete_signed/päth", [Accept: "text/plain"], @config) ==
             %Vimond.Response{
               body: "",
               headers: %{"authorization" => ["Bearer def456", "Bearer abc123"]},
               status_code: 204
             }
  end

  test "get" do
    HTTPClientMock
    |> expect(
      :request,
      fn :get,
         "https://vimond-rest-api.example.com/api/get/p%C3%A4th",
         [{"Content-Type", "application/json"}],
         "",
         timeout: _ ->
        {:ok, %Mojito.Response{body: "", status_code: 200}}
      end
    )

    assert Vimond.HTTPClient.get("/api/get/päth", ["Content-Type": "application/json"], @config) == %Vimond.Response{
             body: "",
             headers: %{},
             status_code: 200
           }
  end

  test "get with query" do
    HTTPClientMock
    |> expect(
      :request,
      fn :get,
         "https://vimond-rest-api.example.com/api/get/p%C3%A4th?key=val%2520ue",
         [{"Content-Type", "application/json"}],
         "",
         timeout: _ ->
        {:ok, %Mojito.Response{body: "", status_code: 200}}
      end
    )

    assert Vimond.HTTPClient.get("/api/get/päth", %{"key" => "val%20ue"}, ["Content-Type": "application/json"], @config) ==
             %Vimond.Response{body: "", status_code: 200}
  end

  test "get_signed" do
    HTTPClientMock
    |> expect(
      :request,
      fn :get,
         "https://vimond-rest-api.example.com/api/platf%C3%B6rm/get_signed/p%C3%A4th",
         [
           {"Authorization", "SUMO key:/2eNQMZn5zrGM98d4dEf45F/DuM="},
           {"Date", "Wed, 02 Sep 2015 13:24:35 +0000"},
           {"Accept", "text/plain"}
         ],
         "",
         timeout: _ ->
        {:ok, %Mojito.Response{body: "", status_code: 204}}
      end
    )

    assert Vimond.HTTPClient.get_signed("get_signed/päth", [Accept: "text/plain"], @config) ==
             %Vimond.Response{body: "", status_code: 204}
  end

  test "post" do
    HTTPClientMock
    |> expect(:request, fn :post,
                           "https://vimond-rest-api.example.com/api/post/p%C3%A4th",
                           [{"Content-Type", "application/json; v=2; charset=UTF-8"}],
                           "body",
                           timeout: _ ->
      {:ok,
       %Mojito.Response{
         status_code: 200,
         body: "",
         headers: [{"content-type", "text/plain"}]
       }}
    end)

    headers = ["Content-Type": "application/json; v=2; charset=UTF-8"]

    assert Vimond.HTTPClient.post("/api/post/päth", "body", headers, @config) == %Vimond.Response{
             status_code: 200,
             body: "",
             headers: %{"content-type" => "text/plain"}
           }
  end

  test "post_signed" do
    HTTPClientMock
    |> expect(:request, fn :post,
                           "https://vimond-rest-api.example.com/api/platf%C3%B6rm/post_signed/p%C3%A4th",
                           [
                             {"Authorization", "SUMO key:JVpWxOkvgRWirA2D6f2uv7q62wU="},
                             {"Date", "Wed, 02 Sep 2015 13:24:35 +0000"},
                             {"Accept", "text/plain"}
                           ],
                           "body",
                           timeout: _ ->
      {:ok, %Mojito.Response{status_code: 200, body: ""}}
    end)

    assert Vimond.HTTPClient.post_signed("post_signed/päth", "body", [Accept: "text/plain"], @config) ==
             %Vimond.Response{status_code: 200, body: ""}
  end

  test "put" do
    HTTPClientMock
    |> expect(
      :request,
      fn :put,
         "https://vimond-rest-api.example.com/api/put/p%C3%A4th",
         [{"Content-Type", "application/json"}],
         "body",
         timeout: _ ->
        {:ok, %Mojito.Response{body: "", status_code: 200}}
      end
    )

    assert Vimond.HTTPClient.put("/api/put/päth", "body", ["Content-Type": "application/json"], @config) ==
             %Vimond.Response{body: "", status_code: 200}
  end

  test "put_signed" do
    HTTPClientMock
    |> expect(:request, fn :put,
                           "https://vimond-rest-api.example.com/api/platf%C3%B6rm/put_signed/p%C3%A4th",
                           [
                             {"Authorization", "SUMO key:eDYzJ3v7hLIacu6NsANcGqPYG6k="},
                             {"Date", "Wed, 02 Sep 2015 13:24:35 +0000"},
                             {"Accept", "text/plain"}
                           ],
                           "body",
                           timeout: _ ->
      {:ok, %Mojito.Response{status_code: 200, body: ""}}
    end)

    assert Vimond.HTTPClient.put_signed("put_signed/päth", "body", [Accept: "text/plain"], @config) ==
             %Vimond.Response{status_code: 200, body: ""}
  end
end
