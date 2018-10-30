defmodule HTTPClient do
  @callback post(url :: String.t(), body :: String.t(), headers :: Keyword.t()) :: any()
  @callback put(url :: String.t(), body :: String.t(), headers :: Keyword.t()) :: any()
  @callback get(url :: String.t(), headers :: Keyword.t()) :: any()
  @callback delete(url :: String.t(), headers :: Keyword.t()) :: any()
  @callback request(method :: Atom.t(), url :: String.t(), options :: Keyword.t()) :: any()
end
