defmodule Vimond.HTTPClient do
  alias Vimond.Config
  require Logger

  @http_client Application.get_env(:vimond_client, :http_client, HTTPotion)

  @callback delete(url :: String.t(), headers :: Keyword.t(), config :: Config.t()) :: any()
  def delete(path, headers, %Config{base_url: base_url}) do
    request(:delete, vimond_url(base_url, path), merge(headers, []))
  end

  @callback delete_signed(path :: String.t(), headers :: Keyword.t(), config :: Config.t()) ::
              any()
  def delete_signed(path, headers, config = %Config{base_url: base_url}) do
    url = vimond_url(base_url, path)
    path = URI.parse(url).path

    headers = headers |> signed_headers("DELETE", path, config)
    request(:delete, url, merge(headers, []))
  end

  @callback get(path :: String.t(), headers :: Keyword.t(), config :: Config.t()) :: any()
  def get(path, headers \\ [], %Config{base_url: base_url}) do
    request(:get, vimond_url(base_url, path), merge(headers, []))
  end

  @callback get_signed(path :: String.t(), headers :: Keyword.t(), config :: Config.t()) :: any()
  def get_signed(path, headers, config = %Config{base_url: base_url}) do
    url = vimond_url(base_url, path)
    path = URI.parse(url).path

    headers = headers |> signed_headers("GET", path, config)
    request(:get, url, merge(headers, []))
  end

  @callback post(
              path :: String.t(),
              body :: String.t(),
              headers :: Keyword.t(),
              config :: Config.t()
            ) :: any()
  def post(path, body, headers, %Config{base_url: base_url}) do
    request(:post, vimond_url(base_url, path), merge(body, headers, []))
  end

  @callback post_signed(
              path :: String.t(),
              body :: String.t(),
              headers :: Keyword.t(),
              config :: Config.t()
            ) :: any()
  def post_signed(path, body, headers, config = %Config{base_url: base_url}) do
    url = vimond_url(base_url, path)
    path = URI.parse(url).path

    headers = headers |> signed_headers("POST", path, config)
    request(:post, url, merge(body, headers, []))
  end

  @callback put(
              path :: String.t(),
              body :: String.t(),
              headers :: Keyword.t(),
              config :: Config.t()
            ) :: any()
  def put(path, body, headers, %Config{base_url: base_url}) do
    request(:put, vimond_url(base_url, path), merge(body, headers, []))
  end

  @callback put_signed(
              path :: String.t(),
              body :: String.t(),
              headers :: Keyword.t(),
              config :: Config.t()
            ) :: any()

  defp request(method, url, options) do
    Logger.debug("Vimond request: #{inspect({method, url, options})}")
    @http_client.request(method, url, options)
  end

  defp merge(headers, options), do: Keyword.merge(options, headers: headers)
  defp merge(body, headers, options), do: Keyword.merge(options, body: body, headers: headers)

  defp vimond_url(base_url, path) do
    base_url
    |> URI.merge(path)
    |> to_string
  end

  defp signed_headers(headers, method, path, %Config{api_key: key, api_secret: secret}) do
    timestamp = Timex.format!(datetime().utc_now(), "{RFC1123}")

    [
      Authorization: "SUMO #{key}:#{vimond_signature(method, path, timestamp, secret)}",
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
