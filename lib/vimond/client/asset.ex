defmodule Vimond.Client.Asset do
  defmacro __using__(_) do
    quote do
      alias Vimond.{Asset, Config, Subtitle, ProductGroup, PaymentPlan, Product, ProductPayment}

      @callback asset_product_groups(binary | integer, Config.t()) :: {:ok, list(ProductGroup.t())} | error
      def asset_product_groups(asset_id, config) do
        request("asset_product_groups", fn ->
          @http_client.get("asset/#{asset_id}/productgroups", headers(), config)
        end)
        |> handle_response(fn
          %{"productGroups" => product_groups}, _headers ->
            {:ok, Enum.map(product_groups, &to_product_group/1)}

          %{"error" => %{"code" => "ASSET_NOT_FOUND", "description" => description}}, _headers ->
            {:error, %{type: :asset_not_found, source_errors: [description]}}

          %{"error" => %{"code" => "ASSET_NOT_PUBLISHED", "description" => description}}, _headers ->
            {:error, %{type: :asset_not_published, source_errors: [description]}}

          _, _headers ->
            {:error, %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
        end)
      end

      @callback asset(binary | integer, Config.t()) :: {:ok, Asset.t()} | error
      def asset(asset_id, config) do
        request("asset", fn ->
          @http_client.get("asset/#{asset_id}", headers(), config)
        end)
        |> handle_response(fn
          %{"title" => title}, _headers ->
            {:ok, %Asset{title: title}}

          %{"error" => %{"code" => "ASSET_NOT_FOUND", "description" => description}}, _headers ->
            {:error, %{type: :asset_not_found, source_errors: [description]}}

          %{"error" => %{"code" => "ASSET_NOT_PUBLISHED", "description" => description}}, _headers ->
            {:error, %{type: :asset_not_published, source_errors: [description]}}

          _, _headers ->
            {:error, %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
        end)
      end

      defp to_product_group(product_group) do
        %ProductGroup{
          id: product_group["id"],
          name: product_group["name"],
          description: product_group["description"],
          sale_status: product_group["saleStatus"],
          sort_index: product_group["sortIndex"],
          products: get_in(product_group, ["productsUri", "products"]) |> Enum.map(&to_product/1)
        }
      end

      defp to_product(product) do
        %Product{
          id: product["id"],
          currency: product["currency"],
          description: product["description"],
          enabled: product["enabled"],
          minimum_periods: product["minimumPeriods"],
          payment_plan: %PaymentPlan{
            name: get_in(product, ["paymentPlan", "name"]),
            payment_type: get_in(product, ["paymentPlan", "paymentType"]),
            period: get_in(product, ["paymentPlan", "period"])
          },
          price: product["price"],
          product_group_id: product["productGroupId"],
          product_payments_uri: product["productPaymentsUri"]["uri"],
          product_status: product["productStatus"],
          sort_index: product["sortIndex"],
          product_payments:
            (get_in(product, ["productPayments", "productPaymentList"]) || [])
            |> Enum.map(&to_product_payment/1)
        }
      end

      defp to_product_payment(product_payment) do
        %ProductPayment{
          auto_renew_warning_enabled: product_payment["autoRenewWarningEnabled"],
          autorenew_warning_channel: product_payment["autorenewWarningChannel"],
          description: product_payment["description"],
          discounted_price: product_payment["discountedPrice"],
          enabled: product_payment["enabled"],
          id: product_payment["id"],
          init_period: product_payment["initPeriod"],
          init_price: product_payment["initPrice"],
          payment_object_uri: get_in(product_payment, ["paymentObjectUri", "uri"]),
          payment_provider_id: product_payment["paymentProviderId"],
          product_id: product_payment["productId"],
          product_payment_status: product_payment["productPaymentStatus"],
          recurring_discounted_price: product_payment["recurringDiscountedPrice"],
          recurring_price: product_payment["recurringPrice"],
          sort_index: product_payment["sortIndex"],
          uri: product_payment["uri"]
        }
      end

      @callback subtitles(binary | integer, Config.t()) :: {:ok, list(Subtitle.t())} | {:error, map()}
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
