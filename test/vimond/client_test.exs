defmodule Vimond.ClientTest do
  use ExUnit.Case, async: true
  import Vimond.Client

  describe "handle_response" do
    test "with an error" do
      response = %Vimond.Error{message: "some error"}

      assert handle_response(response, :never_called) ==
               {:error, %{type: :http_error, source_errors: ["some error"]}}
    end

    test "with unexpected json" do
      response = %Vimond.Response{body: "bad json"}

      assert handle_response(response, :never_called) ==
               {:error, %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
    end

    test "with a successful response" do
      response = %Vimond.Response{
        body: Jason.encode!(%{"code" => "SESSION_AUTHENTICATED"}),
        headers: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
      }

      assert handle_response(response, fn _, _ -> {:ok, %{}} end) == {:ok, %{}}
    end
  end
end
