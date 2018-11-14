defmodule Vimond.ClientTest do
  use ExUnit.Case, async: true
  import Vimond.Client

  describe "handle_response" do
    test "with an error" do
      response = %HTTPotion.ErrorResponse{message: "some error"}

      assert handle_response(response, :never_called) ==
               {:error, %{type: :http_error, source_errors: ["some error"]}}
    end

    test "with a successful response" do
      response = %HTTPotion.Response{
        body: Jason.encode!(%{"code" => "SESSION_AUTHENTICATED"}),
        headers: %HTTPotion.Headers{
          hdrs: %{"content-type" => "application/json; v=\"3\";charset=UTF-8"}
        }
      }

      assert handle_response(response, fn _, _ -> {:ok, %{}} end) == {:ok, %{}}
    end
  end
end
