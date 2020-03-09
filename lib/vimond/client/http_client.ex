defmodule Vimond.HTTPClient do
  alias Vimond.Config
  require Logger

  @http_client Application.get_env(:vimond_client, :http_client, HTTPoison)

  @callback delete(url :: binary, headers :: Keyword.t(), config :: Config.t()) :: any()
  def delete(path, headers, %Config{base_url: base_url}) do
    request(:delete, vimond_url(base_url, path), headers, "", [])
  end

  @callback delete_signed(path :: binary, headers :: Keyword.t(), config :: Config.t()) :: any()
  def delete_signed(path, headers, config = %Config{base_url: base_url}) do
    url = vimond_url(base_url, path)
    path = URI.parse(url).path

    headers = headers |> signed_headers("DELETE", path, config)
    request(:delete, url, headers, "", [])
  end

  @callback get(path :: binary, query :: map(), headers :: Keyword.t(), config :: Config.t()) :: any()
  def get(path, query, headers, %Config{base_url: base_url}) do
    request(:get, vimond_url(base_url, path, query), headers, "", [])
  end

  @callback get(path :: binary, headers :: Keyword.t(), config :: Config.t()) :: any()
  def get(path, headers, %Config{base_url: base_url}) do
    request(:get, vimond_url(base_url, path), headers, "", [])
  end

  @callback get_signed(path :: binary, headers :: Keyword.t(), config :: Config.t()) :: any()
  def get_signed(path, headers, config = %Config{base_url: base_url}) do
    url = vimond_url(base_url, path)
    path = URI.parse(url).path

    headers = headers |> signed_headers("GET", path, config)
    request(:get, url, headers, "", [])
  end

  @callback post(path :: binary, body :: binary, headers :: Keyword.t(), config :: Config.t()) :: any()
  def post(path, body, headers, %Config{base_url: base_url}) do
    request(:post, vimond_url(base_url, path), headers, body, [])
  end

  @callback post_signed(path :: binary, body :: binary, headers :: Keyword.t(), config :: Config.t()) :: any()
  def post_signed(path, body, headers, config = %Config{base_url: base_url}) do
    url = vimond_url(base_url, path)
    path = URI.parse(url).path

    headers = headers |> signed_headers("POST", path, config)
    request(:post, url, headers, body, [])
  end

  @callback put(path :: binary, body :: binary, headers :: Keyword.t(), config :: Config.t()) :: any()
  def put(path, body, headers, %Config{base_url: base_url}) do
    request(:put, vimond_url(base_url, path), headers, body, [])
  end

  @callback put_signed(path :: binary, body :: binary, headers :: Keyword.t(), config :: Config.t()) :: any()
  def put_signed(path, body, headers, config = %Config{base_url: base_url}) do
    url = vimond_url(base_url, path)
    path = URI.parse(url).path

    headers = headers |> signed_headers("PUT", path, config)
    request(:put, url, headers, body, [])
  end

  defp request(method, url, headers, body, options) do
    Logger.debug("Vimond request: #{inspect({method, url, body, headers, options})}")
    headers = Enum.map(headers, fn {key, value} -> {to_string(key), value} end)

    @http_client.request(method, url, body, headers, Keyword.merge(options, recv_timeout: timeout()))
    |> translate_response
  end

  defp translate_response({:error, %HTTPoison.Error{reason: message}}) do
    %Vimond.Error{message: message}
  end

  defp translate_response({:ok, %HTTPoison.Response{body: body, headers: headers, status_code: status_code}}) do
    headers =
      Enum.reduce(headers, %{}, fn {key, value}, headers ->
        Map.update(headers, String.downcase(key), value, fn
          current_value when is_list(current_value) -> [value | current_value]
          current_value -> [value | [current_value]]
        end)
      end)

    %Vimond.Response{body: body, status_code: status_code, headers: headers}
  end

  defp vimond_url(base_url, path) do
    uri = URI.merge(base_url, path)

    %URI{uri | path: URI.encode(uri.path)}
    |> to_string
  end

  defp vimond_url(base_url, path, query) do
    uri = URI.merge(base_url, path)

    %URI{uri | path: URI.encode(uri.path), query: Plug.Conn.Query.encode(query)}
    |> to_string
  end

  defp signed_headers(headers, method, path, %Config{api_key: key, api_secret: secret}) do
    timestamp = Calendar.DateTime.Format.rfc2822(datetime().utc_now())

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

  defp timeout, do: Application.get_env(:vimond_client, :timeout, 10_000)
end
