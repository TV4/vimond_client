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
         headers: [Accept: "text/plain"] ->
        %HTTPotion.Response{body: "", headers: %HTTPotion.Headers{}, status_code: 204}
      end
    )

    Vimond.HTTPClient.delete("delete/päth", [Accept: "text/plain"], @config)
  end

  test "delete_signed" do
    HTTPClientMock
    |> expect(
      :request,
      fn :delete,
         "https://vimond-rest-api.example.com/api/platf%C3%B6rm/delete_signed/p%C3%A4th",
         headers: [
           Authorization: "SUMO key:2m4KdoMUScnkGqcqeMjhD+eC9LM=",
           Date: "Wed, 02 Sep 2015 13:24:35 +0000",
           Accept: "text/plain"
         ] ->
        %HTTPotion.Response{body: "", headers: %HTTPotion.Headers{}, status_code: 204}
      end
    )

    Vimond.HTTPClient.delete_signed("delete_signed/päth", [Accept: "text/plain"], @config)
  end

  test "get" do
    HTTPClientMock
    |> expect(
      :request,
      fn :get, "https://vimond-rest-api.example.com/api/get/p%C3%A4th", headers: ["Content-Type": "application/json"] ->
        %HTTPotion.Response{body: "", headers: %HTTPotion.Headers{}, status_code: 200}
      end
    )

    Vimond.HTTPClient.get("/api/get/päth", ["Content-Type": "application/json"], @config)
  end

  test "get_signed" do
    HTTPClientMock
    |> expect(
      :request,
      fn :get,
         "https://vimond-rest-api.example.com/api/platf%C3%B6rm/get_signed/p%C3%A4th",
         headers: [
           Authorization: "SUMO key:/2eNQMZn5zrGM98d4dEf45F/DuM=",
           Date: "Wed, 02 Sep 2015 13:24:35 +0000",
           Accept: "text/plain"
         ] ->
        %HTTPotion.Response{body: "", headers: %HTTPotion.Headers{}, status_code: 204}
      end
    )

    Vimond.HTTPClient.get_signed("get_signed/päth", [Accept: "text/plain"], @config)
  end

  test "post" do
    HTTPClientMock
    |> expect(:request, fn :post,
                           "https://vimond-rest-api.example.com/api/post/p%C3%A4th",
                           body: "body",
                           headers: ["Content-Type": "application/json; v=2; charset=UTF-8"] ->
      %HTTPotion.Response{
        status_code: 200,
        body: "",
        headers: %HTTPotion.Headers{hdrs: %{"content-type" => "text/plain"}}
      }
    end)

    headers = ["Content-Type": "application/json; v=2; charset=UTF-8"]

    Vimond.HTTPClient.post("/api/post/päth", "body", headers, @config)
  end

  test "post_signed" do
    HTTPClientMock
    |> expect(:request, fn :post,
                           "https://vimond-rest-api.example.com/api/platf%C3%B6rm/post_signed/p%C3%A4th",
                           body: "body",
                           headers: [
                             Authorization: "SUMO key:JVpWxOkvgRWirA2D6f2uv7q62wU=",
                             Date: "Wed, 02 Sep 2015 13:24:35 +0000",
                             Accept: "text/plain"
                           ] ->
      %HTTPotion.Response{status_code: 200, body: ""}
    end)

    Vimond.HTTPClient.post_signed("post_signed/päth", "body", [Accept: "text/plain"], @config)
  end

  test "put" do
    HTTPClientMock
    |> expect(
      :request,
      fn :put,
         "https://vimond-rest-api.example.com/api/put/p%C3%A4th",
         body: "body",
         headers: ["Content-Type": "application/json"] ->
        %HTTPotion.Response{body: "", headers: %HTTPotion.Headers{}, status_code: 200}
      end
    )

    Vimond.HTTPClient.put("/api/put/päth", "body", ["Content-Type": "application/json"], @config)
  end

  test "put_signed" do
    HTTPClientMock
    |> expect(:request, fn :put,
                           "https://vimond-rest-api.example.com/api/platf%C3%B6rm/put_signed/p%C3%A4th",
                           body: "body",
                           headers: [
                             Authorization: "SUMO key:eDYzJ3v7hLIacu6NsANcGqPYG6k=",
                             Date: "Wed, 02 Sep 2015 13:24:35 +0000",
                             Accept: "text/plain"
                           ] ->
      %HTTPotion.Response{status_code: 200, body: ""}
    end)

    Vimond.HTTPClient.put_signed("put_signed/päth", "body", [Accept: "text/plain"], @config)
  end
end
