defmodule Vimond.Client.Asset do
  defmacro __using__(_) do
    quote do
      alias Vimond.{Config, Subtitle}

      @callback subtitles(String.t(), Config.t()) :: {:ok, list(Subtitle.t())} | {:error, map()}
      def subtitles(asset_id, config) do
        request("subtitles", fn ->
          @http_client.get("asset/#{asset_id}/subtitles", headers(), config)
        end)
        |> handle_response(fn json, _headers ->
          subtitles =
            json
            |> Enum.map(fn subtitle ->
              %Subtitle{
                asset_id: Map.get(subtitle, "assetId"),
                content_type: Map.get(subtitle, "contentType"),
                id: Map.get(subtitle, "id"),
                locale: Map.get(subtitle, "locale"),
                name: Map.get(subtitle, "name"),
                type: Map.get(subtitle, "type"),
                uri: Map.get(subtitle, "uri")
              }
            end)

          {:ok, subtitles}
        end)
      end
    end
  end
end
