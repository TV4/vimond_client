defmodule Vimond.HTTPClientTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "delete" do
    HTTPClientMock
    |> expect(
      :request,
      fn :delete,
         "https://vimond-rest-api.example.com/api/delete",
         headers: ["Content-Type": "application/json"] ->
        %HTTPotion.Response{body: "", headers: %HTTPotion.Headers{}, status_code: 204}
      end
    )

    Vimond.HTTPClient.delete(
      "https://vimond-rest-api.example.com/api/delete",
      "Content-Type": "application/json"
    )
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

    Vimond.HTTPClient.get(
      "https://vimond-rest-api.example.com/api/get",
      "Content-Type": "application/json"
    )
  end

  test "post" do
    HTTPClientMock
    |> expect(:request, fn :post,
                           "https://vimond-rest-api.example.com/api/authentication/user/login",
                           body: "body",
                           headers: ["Content-Type": "application/json; v=2; charset=UTF-8"] ->
      %HTTPotion.Response{
        status_code: 200,
        body: "",
        headers: %HTTPotion.Headers{hdrs: %{"content-type" => "text/plain"}}
      }
    end)

    Vimond.HTTPClient.post(
      "https://vimond-rest-api.example.com/api/authentication/user/login",
      "body",
      "Content-Type": "application/json; v=2; charset=UTF-8"
    )
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
      "https://vimond-rest-api.example.com/api/put",
      "body",
      "Content-Type": "application/json"
    )
  end
end
