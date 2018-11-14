defmodule HTTPClient do
  @callback request(method :: atom(), url :: String.t(), options :: Keyword.t()) :: HTTPotion.Response.t() | HTTPotion.ErrorResponse.t()
end
