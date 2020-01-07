defmodule HTTPClient do
  @callback request(
              method :: atom(),
              url :: String.t(),
              headers :: Keyword.t(),
              body :: String.t(),
              options :: Keyword.t()
            ) ::
              {:ok, Mojito.Response.t()} | {:error, Mojito.Error.t()}
end
