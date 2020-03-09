defmodule Vimond.Client.Asset do
  defmacro __using__(_) do
    quote do
      alias Vimond.{Asset, Config, Subtitle}

      @callback asset(binary, Config.t()) :: {:ok, Asset.t()}
      def asset(asset_id, config) do
        request("asset", fn ->
          @http_client.get("asset/#{asset_id}/productgroups", headers(), config)
        end)
        |> handle_response(fn
          %{"productGroups" => product_groups}, _headers ->
            product_group_ids = Enum.map(product_groups, &Map.get(&1, "id"))

            {:ok, %Asset{product_group_ids: product_group_ids}}

          %{"error" => %{"code" => "ASSET_NOT_FOUND", "description" => description}}, _headers ->
            {:error, %{type: :asset_not_found, source_errors: [description]}}

          %{"error" => %{"code" => "ASSET_NOT_PUBLISHED", "description" => description}}, _headers ->
            {:error, %{type: :asset_not_published, source_errors: [description]}}

          _, _headers ->
            {:error, %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
        end)
      end

      @callback subtitles(binary, Config.t()) :: {:ok, list(Subtitle.t())} | {:error, map()}
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
