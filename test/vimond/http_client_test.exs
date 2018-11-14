defmodule Vimond.HTTPClientTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  @config %Vimond.Config{
    api_key: "key",
    api_secret: "secret",
    base_url: "https://vimond-rest-api.example.com/api/platform/"
  }

  test "delete" do
    HTTPClientMock
    |> expect(
      :request,
      fn :delete,
         "https://vimond-rest-api.example.com/api/platform/delete",
         headers: [Accept: "text/plain"] ->
        %HTTPotion.Response{body: "", headers: %HTTPotion.Headers{}, status_code: 204}
      end
    )

    Vimond.HTTPClient.delete("delete", [Accept: "text/plain"], @config)
  end

  test "delete_signed" do
    HTTPClientMock
    |> expect(
      :request,
      fn :delete,
         "https://vimond-rest-api.example.com/api/platform/delete_signed",
         headers: [
           Authorization: "SUMO key:PAD6KGCi1CkhzfvvC9meQzIFBLk=",
           Date: "Wed, 02 Sep 2015 13:24:35 +0000",
           Accept: "text/plain"
         ] ->
        %HTTPotion.Response{body: "", headers: %HTTPotion.Headers{}, status_code: 204}
      end
    )

    Vimond.HTTPClient.delete_signed("delete_signed", [Accept: "text/plain"], @config)
  end

  test "get" do
    HTTPClientMock
    |> expect(
      :request,
      fn :get,
         "https://vimond-rest-api.example.com/api/get",
         headers: ["Content-Type": "application/json"] ->
        %HTTPotion.Response{body: "", headers: %HTTPotion.Headers{}, status_code: 200}
      end
    )

    Vimond.HTTPClient.get("/api/get", ["Content-Type": "application/json"], @config)
  end

  test "get_signed" do
    HTTPClientMock
    |> expect(
      :request,
      fn :get,
         "https://vimond-rest-api.example.com/api/platform/get_signed",
         headers: [
           Authorization: "SUMO key:5ZB2O9WWPFTXVUfsSz6DCaEV2Xw=",
           Date: "Wed, 02 Sep 2015 13:24:35 +0000",
           Accept: "text/plain"
         ] ->
        %HTTPotion.Response{body: "", headers: %HTTPotion.Headers{}, status_code: 204}
      end
    )

    Vimond.HTTPClient.get_signed("get_signed", [Accept: "text/plain"], @config)
  end

  test "post" do
    HTTPClientMock
    |> expect(:request, fn :post,
                           "https://vimond-rest-api.example.com/api/post",
                           body: "body",
                           headers: ["Content-Type": "application/json; v=2; charset=UTF-8"] ->
      %HTTPotion.Response{
        status_code: 200,
        body: "",
        headers: %HTTPotion.Headers{hdrs: %{"content-type" => "text/plain"}}
      }
    end)

    headers = ["Content-Type": "application/json; v=2; charset=UTF-8"]

    Vimond.HTTPClient.post("/api/post", "body", headers, @config)
  end

  test "post_signed" do
    HTTPClientMock
    |> expect(:request, fn :post,
                           "https://vimond-rest-api.example.com/api/platform/post_signed",
                           body: "body",
                           headers: [
                             Authorization: "SUMO key:CU79efCHfV5HZxLsOG4/VH5bGhY=",
                             Date: "Wed, 02 Sep 2015 13:24:35 +0000",
                             Accept: "text/plain"
                           ] ->
      %HTTPotion.Response{status_code: 200, body: ""}
    end)

    Vimond.HTTPClient.post_signed("post_signed", "body", [Accept: "text/plain"], @config)
  end

  test "put" do
    HTTPClientMock
    |> expect(
      :request,
      fn :put,
         "https://vimond-rest-api.example.com/api/put",
         body: "body",
         headers: ["Content-Type": "application/json"] ->
        %HTTPotion.Response{body: "", headers: %HTTPotion.Headers{}, status_code: 200}
      end
    )

    Vimond.HTTPClient.put(
      "/api/put",
      "body",
      ["Content-Type": "application/json"],
      @config
    )
  end
end
