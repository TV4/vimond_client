defmodule Vimond.Client.Order do
  alias Vimond.Order

  defmacro __using__(_) do
    quote do
      import Vimond.Client.Order
      alias Vimond.Config

      @callback add_order_signed(String.t(), Order.t(), Config.t()) :: {:ok, integer} | {:error, :failed_to_add_order}
      def add_order_signed(user_id, order = %Order{}, config = %Config{}) do
        body =
          build_order(order)
          |> Jason.encode!()

        request("add_order_signed", fn ->
          @http_client.post_signed("order/#{user_id}/create", body, headers(), config)
        end)
        |> case do
          %Vimond.Response{body: body, status_code: 200} ->
            case Jason.decode(body) do
              {:ok, %{"id" => order_id}} -> {:ok, order_id}
            end

          error ->
            Logger.error("Error adding order: #{inspect(error)}")
            {:error, :failed_to_add_order}
        end
      end

      @callback current_orders(String.t(), String.t(), String.t(), Config.t()) :: {:ok | :error, map}
      def current_orders(user_id, vimond_authorization_token, remember_me, config = %Config{}) do
        headers = headers_with_tokens(vimond_authorization_token, remember_me)

        request("current_orders", fn ->
          @http_client.get("user/#{user_id}/orders/current", headers, config)
        end)
        |> handle_response(&extract_orders/2)
      end

      def current_orders_signed(user_id, config = %Config{}) do
        request("current_orders", fn ->
          @http_client.get_signed("user/#{user_id}/orders/current", headers(), config)
        end)
        |> handle_response(&extract_orders/2)
      end

      @callback terminate_order_signed(String.t(), Config.t()) :: {:ok | :error, order_id :: String.t()}
      def terminate_order_signed(order_id, config = %Config{}) do
        {:ok, order} = get_order_signed(order_id, config)
        end_date = DateTime.to_unix(datetime().utc_now(), :millisecond)

        body =
          order
          |> Enum.filter(fn {_key, value} -> !is_map(value) end)
          |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
          |> Map.new()
          |> Map.put("accessEndDate", end_date)
          |> Map.put("endDate", end_date)
          |> Jason.encode!()

        request("terminate_order", fn ->
          @http_client.put_signed("order/#{order_id}", body, headers(), config)
        end)
        |> case do
          %Vimond.Response{status_code: 200} -> {:ok, order_id}
          _ -> {:error, order_id}
        end
      end

      @callback update_order_signed(Order.t(), Config.t()) :: {:ok | :error, order_id :: String.t()}
      def update_order_signed(order = %Order{order_id: order_id}, config = %Config{}) do
        request("updated order", fn ->
          @http_client.put_signed(
            "order/#{order_id}",
            Jason.encode!(update_order_payload(order, config)),
            headers(),
            config
          )
        end)
        |> handle_response(&extract_order/2)
      end

      def get_order_signed(order_id, config = %Config{}) do
        request("get_order", fn ->
          @http_client.get_signed("order/#{order_id}", headers(), config)
        end)
        |> case do
          %Vimond.Response{body: body, status_code: 200} -> Jason.decode(body)
        end
      end

      defp datetime, do: Application.get_env(:vimond_client, :datetime, DateTime)
    end
  end

  def build_order(%Order{referrer: referrer, product_payment_id: product_payment_id})
      when not is_nil(referrer) and not is_nil(product_payment_id) do
    %{
      startDate: DateTime.to_unix(datetime().utc_now(), :millisecond),
      productPaymentId: product_payment_id,
      referrer: referrer
    }
  end

  def extract_orders(json, _) do
    case json do
      %{"error" => %{"code" => "UNAUTHORIZED", "description" => reason}} ->
        {:error, %{type: :invalid_credentials, source_errors: [reason]}}

      json when is_list(json) ->
        {:ok, %{orders: Enum.map(json, &transform_order/1)}}

      _ ->
        {:error, %{type: :generic, source_errors: ["Unexpected error"]}}
    end
  end

  def extract_order(json, _) do
    {:ok, transform_order(json)}
  end

  def update_order_payload(order, config) do
    {:ok, old_order} = Vimond.Client.get_order_signed(order.order_id, config)

    old_order =
      old_order
      |> Enum.filter(fn {_key, value} -> !is_map(value) end)
      |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
      |> Map.new()

    order =
      order
      |> Map.from_struct()
      |> Enum.reject(&(elem(&1, 1) == nil))
      |> Enum.flat_map(fn
        {:end_date, value} ->
          [
            {"endDate", value |> DateTime.from_unix!() |> DateTime.to_iso8601()},
            {"accessEndDate", value |> DateTime.from_unix!() |> DateTime.to_iso8601()}
          ]

        {:order_id, value} ->
          [{"id", value}]

        {key, value} ->
          [{key |> Atom.to_string() |> camelize(), value}]
      end)
      |> Map.new()

    Map.merge(old_order, order)
  end

  defp transform_order(order) do
    {:ok, end_date, _offset} = DateTime.from_iso8601(order["endDate"])

    end_date = DateTime.to_unix(end_date)

    %Vimond.Order{
      order_id: order["id"],
      product_id: order["productId"],
      product_group_id: order["productGroupId"],
      asset_id: order["progId"],
      referrer: order["referrer"],
      product_payment_id: order["productPaymentId"],
      end_date: end_date
    }
  end

  defp camelize(snake) do
    [first | rest] =
      snake
      |> Macro.camelize()
      |> String.codepoints()

    [String.downcase(first) | rest] |> Enum.join()
  end

  defp datetime, do: Application.get_env(:vimond_client, :datetime, DateTime)
end
