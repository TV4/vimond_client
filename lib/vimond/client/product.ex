defmodule Vimond.Client.Product do
  require Logger
  alias Vimond.{Payment, PaymentMethod, PaymentPlan, Product, ProductGroup}

  defmacro __using__(_) do
    quote do
      import Vimond.Client.Product
      alias Vimond.Config

      @callback product(String.t(), String.t(), Config.t()) :: {:ok, map} | {:error, String.t()}
      @deprecated "Use product/2 instead. Vimond ignores the product group id."
      def product(product_group_id, product_id, config = %Config{}) do
        request("product", fn ->
          @http_client.get(
            "productgroup/#{product_group_id}/products/#{product_id}",
            headers(),
            config
          )
        end)
        |> handle_product_response
      end

      @callback product(String.t(), Config.t()) :: {:ok, map} | {:error, String.t()}
      def product(product_id, config = %Config{}) do
        product("0", product_id, config)
      end

      @callback products(String.t(), Config.t()) :: {:ok, map} | {:error, String.t()}
      def products(product_group_id, config = %Config{}) do
        request("products", fn ->
          @http_client.get(
            "productgroup/#{product_group_id}/products",
            headers(),
            config
          )
        end)
        |> handle_products_response
      end

      @callback product_groups(Config.t()) :: {:ok | :error, map}
      def product_groups(config = %Config{}) do
        request("product_groups", fn ->
          @http_client.get("productgroup", headers(), config)
        end)
        |> handle_product_groups_response
      end

      @callback product_group(String.t(), Config.t()) :: {:ok | :error, map}
      def product_group(product_group_id, config = %Config{}) do
        request("product_group", fn ->
          @http_client.get("productgroup/#{product_group_id}", headers(), config)
        end)
        |> handle_product_group_response
      end

      @callback payment_methods(String.t(), Config.t()) :: {:ok | :error, map}
      def payment_methods(product_id, config = %Config{}) do
        request("payment_methods", fn ->
          @http_client.get("productgroup/0/products/#{product_id}/productPayments", headers(), config)
        end)
        |> handle_payment_methods_response
      end

      @callback payment_methods(String.t(), String.t(), Config.t()) :: {:ok | :error, map}
      def payment_methods(product_id, voucher_code, config = %Config{}) do
        request("payment_methods", fn ->
          @http_client.get(
            "productgroup/0/products/#{product_id}/productPayments",
            %{voucherCode: voucher_code},
            headers(),
            config
          )
        end)
        |> handle_payment_methods_response(voucher_code)
      end

      @callback payment(String.t(), Config.t()) :: {:ok | :error, map}
      def payment(payment_method_id, config = %Config{}) do
        request("payment", fn ->
          @http_client.get(
            "productgroup/0/products/0/productPayments/#{payment_method_id}/payment",
            headers(),
            config
          )
        end)
        |> handle_payment_response(String.to_integer(payment_method_id))
      end
    end
  end

  def handle_product_response(%HTTPotion.Response{status_code: 200, body: body}) do
    case json = Jason.decode(body) do
      {:ok, json} ->
        {:ok,
         %Product{
           id: json["id"],
           currency: json["currency"],
           description: json["description"],
           enabled: json["enabled"],
           minimum_periods: json["minimumPeriods"],
           payment_plan: %PaymentPlan{
             name: get_in(json, ["paymentPlan", "name"]),
             payment_type: get_in(json, ["paymentPlan", "paymentType"]),
             period: get_in(json, ["paymentPlan", "period"])
           },
           price: json["price"],
           product_group_id: json["productGroupId"],
           product_payments_uri: json["productPaymentsUri"]["uri"],
           product_status: json["productStatus"],
           sort_index: json["sortIndex"]
         }}

      {:error, _} ->
        Logger.error("handle_product_response: Unexpected json: '#{inspect(json)}'")
        {:error, "Failed to parse product"}
    end
  end

  def handle_product_response(response) do
    Logger.error("handle_product_response: Unexpected response: '#{inspect(response)}'")
    {:error, "Failed to fetch product"}
  end

  def handle_products_response(%HTTPotion.Response{status_code: 200, body: body}) do
    case json = Jason.decode(body) do
      {:ok, %{"products" => products}} ->
        {:ok,
         %{
           products:
             Enum.map(products, fn product ->
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
                 sort_index: product["sortIndex"]
               }
             end)
         }}

      _ ->
        Logger.error("handle_products_response: Unexpected json: '#{inspect(json)}'")
        {:error, "Failed to parse products"}
    end
  end

  def handle_products_response(response) do
    Logger.error("handle_products_response: Unexpected response: '#{inspect(response)}'")
    {:error, "Failed to fetch products"}
  end

  def handle_product_groups_response(%HTTPotion.Response{status_code: 200, body: body}) do
    case json = Jason.decode(body) do
      {:ok, json} ->
        {:ok,
         Enum.map(json["productGroups"], fn productGroup ->
           %ProductGroup{
             id: productGroup["id"],
             name: productGroup["name"],
             description: productGroup["description"],
             sale_status: productGroup["saleStatus"],
             sort_index: productGroup["sortIndex"]
           }
         end)}

      _ ->
        Logger.error("handle_product_group_response: Unexpected json: '#{inspect(json)}'")
        {:error, %{name: nil, description: nil, sale_status: nil}}
    end
  end

  def handle_product_groups_response(response) do
    Logger.error("handle_product_groups_response: Unexpected response: '#{inspect(response)}'")

    {:error, "Failed to fetch product groups"}
  end

  def handle_product_group_response(%HTTPotion.Response{status_code: 200, body: body}) do
    case json = Jason.decode(body) do
      {:ok, json} ->
        {:ok,
         %ProductGroup{
           id: json["id"],
           name: json["name"],
           description: json["description"],
           sale_status: json["saleStatus"],
           sort_index: json["sortIndex"]
         }}

      _ ->
        Logger.error("handle_product_group_response: Unexpected json: '#{inspect(json)}'")
        {:error, "Failed to parse product group"}
    end
  end

  def handle_product_group_response(response) do
    Logger.error("handle_product_group_response: Unexpected response: '#{inspect(response)}'")

    {:error, "Failed to fetch product group"}
  end

  def handle_payment_methods_response(response = %HTTPotion.Response{status_code: 404}, _voucher_code) do
    Logger.error("handle_payment_methods_response: Invalid voucher: '#{inspect(response)}'")

    {:error, "Failed to fetch payment methods"}
  end

  def handle_payment_methods_response(response, _voucher_code), do: handle_payment_methods_response(response)

  def handle_payment_methods_response(%HTTPotion.Response{status_code: 200, body: body}) do
    case json = Jason.decode(body) do
      {:ok, json} ->
        {:ok,
         Enum.map(json["productPaymentList"], fn payment_method ->
           %PaymentMethod{
             auto_renew_warning_enabled: payment_method["autoRenewWarningEnabled"],
             autorenew_warning_channel: payment_method["autorenewWarningChannel"],
             description: payment_method["description"],
             discounted_price: payment_method["discountedPrice"],
             enabled: payment_method["enabled"],
             id: payment_method["id"],
             init_period: payment_method["initPeriod"],
             init_price: payment_method["initPrice"],
             payment_object_uri: get_in(payment_method, ["paymentObjectUri", "uri"]),
             payment_provider_id: payment_method["paymentProviderId"],
             product_id: payment_method["productId"],
             product_payment_status: payment_method["productPaymentStatus"],
             recurring_discounted_price: payment_method["recurringDiscountedPrice"],
             recurring_price: payment_method["recurringPrice"],
             sort_index: payment_method["sortIndex"],
             uri: payment_method["uri"]
           }
         end)}

      {:error, _} ->
        Logger.error("handle_payment_methods_response: Unexpected json: '#{inspect(json)}'")
        {:error, "Failed to parse payment methods"}
    end
  end

  def handle_payment_methods_response(response) do
    Logger.error("handle_payment_methods_response: Unexpected response: '#{inspect(response)}'")

    {:error, "Failed to fetch payment methods"}
  end

  def handle_payment_response(%HTTPotion.Response{status_code: 200, body: body}, id) do
    case json = Jason.decode(body) do
      {:ok, json} ->
        {:ok, %Payment{id: id, name: json["name"], payment_method: json["paymentMethod"], url: json["url"]}}

      {:error, _} ->
        Logger.error("handle_payment_response: Unexpected json: '#{inspect(json)}'")
        {:error, "Failed to parse payment"}
    end
  end

  def handle_payment_response(response, _) do
    Logger.error("handle_payment_response: Unexpected response: '#{inspect(response)}'")

    {:error, "Failed to fetch payment"}
  end
end
