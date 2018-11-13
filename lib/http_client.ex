defmodule HTTPClient do
  require Logger

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

  defp request(method, url, options) do
    Logger.debug("Vimond request: #{inspect({method, url, options})}")
    HTTPotion.request(method, url, options)
  end

  defp merge(headers, options), do: Keyword.merge(options, headers: headers)
  defp merge(body, headers, options), do: Keyword.merge(options, body: body, headers: headers)
end
