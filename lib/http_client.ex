defmodule HTTPClient do
  alias Vimond.Config
  require Logger

  @http_client Application.get_env(:vimond_client, :http_client)

  @callback delete(url :: String.t(), headers :: Keyword.t()) :: any()
  def delete(url, headers, options \\ []) do
    request(:delete, url, merge(headers, options))
  end

  @callback get(url :: String.t(), headers :: Keyword.t()) :: any()
  def get(url, headers \\ [], options \\ []) do
    request(:get, url, merge(headers, options))
  end

  @callback post(url :: String.t(), body :: String.t(), headers :: Keyword.t()) :: any()
  def post(url, body, headers, options \\ []) do
    request(:post, url, merge(body, headers, options))
  end

  @callback put(url :: String.t(), body :: String.t(), headers :: Keyword.t()) :: any()
  def put(url, body, headers, options \\ []) do
    request(:put, url, merge(body, headers, options))
  end

  @callback request(method :: atom(), url :: String.t(), options :: Keyword.t()) ::
              HTTPotion.Response.t() | HTTPotion.ErrorResponse.t()
  def request(method, url, options) do
    Logger.debug("Vimond request: #{inspect({method, url, options})}")
    @http_client.request(method, url, options)
  end

  defp merge(headers, options), do: Keyword.merge(options, headers: headers)
  defp merge(body, headers, options), do: Keyword.merge(options, body: body, headers: headers)

  defp sign_headers(method, path, headers, %Config{api_key: api_key, api_secret: api_secret}) do
    timestamp = Timex.format!(datetime().utc_now(), "{RFC1123}")

    [
      Authorization: "SUMO #{api_key}:#{vimond_signature(method, path, timestamp, api_secret)}",
      Date: timestamp
    ]
    |> Keyword.merge(headers)
  end

  def vimond_signature(method, path, timestamp, api_secret) do
    :crypto.hmac(:sha, api_secret, "#{method}\n#{path}\n#{timestamp}")
    |> Base.encode64()
  end

  defp datetime, do: Application.get_env(:vimond_client, :datetime, DateTime)
end
