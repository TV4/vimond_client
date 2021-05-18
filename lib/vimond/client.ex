defmodule Vimond.Client do
  require Logger
  alias TimeConverter

  @type error :: {:error, %{type: atom, source_errors: list(binary)}}

  @http_client Application.get_env(:vimond_client, :vimond_http_client, Vimond.HTTPClient)

  use Vimond.Client.User
  use Vimond.Client.Order
  use Vimond.Client.Product
  use Vimond.Client.Voucher
  use Vimond.Client.Asset

  defp request(log_message, request_function) do
    Logger.info("count#outgoing.vimond.#{log_message}.start=1")
    {time, vimond_response} = :timer.tc(request_function)
    Logger.debug("Vimond response for #{log_message}: #{inspect(vimond_response)}")

    Logger.info(
      "Vimond request time: measure#vimond.#{log_message}=#{div(time, 1000)}ms count#outgoing.vimond.#{log_message}.end=1"
    )

    vimond_response
  end

  @doc """
  Only made public for ease of testing.
  """
  def handle_response(
        %Vimond.Response{body: body, headers: headers},
        extraction_function
      ) do
    case Jason.decode(body) do
      {:ok, json} ->
        extraction_function.(json, headers)

      _ ->
        {:error, %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
    end
  end

  def handle_response(%Vimond.Error{message: reason}, _) do
    {:error, %{type: :http_error, source_errors: [reason]}}
  end

  defp headers(headers \\ []) do
    Keyword.merge(
      [
        Accept: "application/json; v=3; charset=UTF-8",
        "Content-Type": "application/json; v=3; charset=UTF-8"
      ],
      headers
    )
  end

  defp headers_with_tokens(vimond_authorization_token, remember_me) do
    headers(
      Authorization: "Bearer #{vimond_authorization_token}",
      Cookie: "rememberMe=#{remember_me}"
    )
  end

  defp headers_with_tokens(vimond_authorization_token, remember_me, jsessionid) do
    headers(
      Authorization: "Bearer #{vimond_authorization_token}",
      Cookie: "rememberMe=#{remember_me}",
      Cookie: "JSESSIONID=#{jsessionid}"
    )
  end
end
