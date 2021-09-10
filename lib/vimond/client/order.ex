defmodule Vimond.Client.Order do
  alias Vimond.Order

  defmacro __using__(_) do
    quote do
      import Vimond.Client.Order
      alias Vimond.Config

      @callback add_order_signed(binary, Order.t(), Config.t()) :: {:ok, integer} | {:error, :failed_to_add_order}
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

      @callback initialize_order_payment_signed(binary, Order.t(), Config.t()) ::
                  {:ok, map} | {:error, :failed_to_initialize_order}
      def initialize_order_payment_signed(user_id, %Order{product_payment_id: product_payment_id}, config = %Config{}) do
        body =
          %{
            "userId" => String.to_integer(user_id),
            "productPaymentId" => product_payment_id
          }
          |> Jason.encode!()

        request("initialize_order_payment_signed", fn ->
          @http_client.post_signed("order", body, headers(), config)
        end)
        |> case do
          %Vimond.Response{body: body, status_code: 200} ->
            case Jason.decode(body) do
              {:ok, %{"id" => order_id, "paymentObject" => %{"url" => url}}} ->
                {:ok, %{order_id: order_id, payment_url: url}}
            end

          error ->
            Logger.error("Error initializing order: #{inspect(error)}")
            {:error, :failed_to_initialize_order}
        end
      end

      @callback complete_order_payment_signed(
                  vimond_user_id :: binary,
                  returned_payment_data :: binary,
                  config :: Vimond.Config.t()
                ) :: {:ok, order_id :: integer}
      def complete_order_payment_signed(vimond_user_id, returned_payment_data, config) do
      end

      @callback all_orders_signed(binary, Config.t()) :: {:ok, %{orders: [Order.t()]}} | error()
      def all_orders_signed(user_id, config = %Config{}) do
        response =
          request("orders", fn -> @http_client.get_signed("user/#{user_id}/orders", headers(), config) end)
          |> handle_response(&extract_orders/2)

        with {:ok, %{orders: orders}} <- response do
          {:ok, %{orders: order_history}} =
            request("order_history", fn ->
              @http_client.get_signed("user/#{user_id}/orders/history", headers(), config)
            end)
            |> handle_response(&extract_orders/2)

          {:ok, %{orders: Enum.concat(orders, order_history)}}
        end
      end

      @callback current_orders(binary, Vimond.Session.t(), Config.t()) :: {:ok, %{orders: [Order.t()]}} | error()
      def current_orders(
            user_id,
            %Vimond.Session{
              vimond_authorization_token: vimond_authorization_token,
              vimond_remember_me: remember_me,
              vimond_jsessionid: jsessionid
            },
            config
          ) do
        current_orders(user_id, vimond_authorization_token, remember_me, jsessionid, config)
      end

      @callback current_orders(binary, binary, binary, Config.t()) ::
                  {:ok, %{orders: [Order.t()]}} | error()
      @callback current_orders(binary, binary, binary, binary | atom, Config.t()) ::
                  {:ok, %{orders: [Order.t()]}} | error()
      @deprecated "Use current_orders/3 instead"
      def current_orders(
            user_id,
            vimond_authorization_token,
            remember_me,
            jsessionid \\ :no_jsessionid,
            config = %Config{}
          ) do
        headers = headers_with_tokens(vimond_authorization_token, remember_me, jsessionid)

        request("current_orders", fn ->
          @http_client.get("user/#{user_id}/orders/current", headers, config)
        end)
        |> handle_response(&extract_orders/2)
      end

      @callback current_orders_signed(binary, Config.t()) :: {:ok, %{orders: [Order.t()]}} | error()
      def current_orders_signed(user_id, config = %Config{}) do
        request("current_orders", fn ->
          @http_client.get_signed("user/#{user_id}/orders/current", headers(), config)
        end)
        |> handle_response(&extract_orders/2)
      end

      @callback terminate_order_signed(integer, Config.t()) :: {:ok | :error, order_id :: integer}
      def terminate_order_signed(order_id, config = %Config{}) do
        with {:ok, %{order: old_order, date_time: date_time}} <- get_order_for_update(order_id, config) do
          request("terminate_order", fn ->
            @http_client.put_signed(
              "order/#{order_id}",
              Jason.encode!(update_order_payload(old_order, %Order{end_date: date_time})),
              headers(),
              config
            )
          end)
          |> case do
            %Vimond.Response{status_code: 200} -> {:ok, order_id}
            _ -> {:error, order_id}
          end
        end
      end

      @callback update_order_signed(Order.t(), Config.t()) :: {:ok, Order.t()} | error()
      def update_order_signed(order = %Order{order_id: order_id}, config = %Config{}) do
        with {:ok, %{order: old_order}} <- Vimond.Client.get_order_for_update(order.order_id, config) do
          request("update_order", fn ->
            @http_client.put_signed(
              "order/#{order_id}",
              Jason.encode!(update_order_payload(old_order, order)),
              headers(),
              config
            )
          end)
          |> handle_response(&extract_order/2)
        end
      end

      def get_order_for_update(order_id, config = %Config{}) do
        response =
          request("get_order", fn ->
            @http_client.get_signed("order/#{order_id}", headers(), config)
          end)

        with %Vimond.Response{body: body, headers: %{"date" => date_time}, status_code: 200} <- response,
             {:ok, order} <- Jason.decode(body) do
          order =
            order
            |> Enum.reject(fn {_key, value} -> is_map(value) end)
            |> Enum.reject(fn {_key, value} -> is_nil(value) end)
            |> Map.new()

          date_time =
            date_time
            |> Calendar.DateTime.Parse.httpdate!()
            |> DateTime.to_unix()

          {:ok, %{order: order, date_time: date_time}}
        end
      end

      defp datetime, do: Application.get_env(:vimond_client, :datetime, DateTime)
    end
  end

  def build_order(%Order{referrer: referrer, product_payment_id: product_payment_id, asset_id: asset_id})
      when not is_nil(referrer) and not is_nil(product_payment_id) do
    %{
      startDate: DateTime.to_unix(datetime().utc_now(), :millisecond),
      progId: asset_id,
      productPaymentId: product_payment_id,
      referrer: referrer
    }
    |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
    |> Map.new()
  end

  def extract_orders(json, _) do
    case json do
      %{"error" => %{"code" => "UNAUTHORIZED", "description" => reason}} ->
        {:error, %{type: :invalid_credentials, source_errors: [reason]}}

      orders when is_list(orders) ->
        {:ok, %{orders: Enum.map(orders, &transform_order/1)}}

      %{"active" => active_orders, "future" => future_orders} ->
        orders =
          Enum.concat(active_orders, future_orders)
          |> Enum.map(&transform_order/1)

        {:ok, %{orders: orders}}

      _ ->
        {:error, %{type: :generic, source_errors: ["Unexpected error"]}}
    end
  end

  def extract_order(json, _) do
    {:ok, transform_order(json)}
  end

  def update_order_payload(old_order, order) do
    order =
      order
      |> Map.from_struct()
      |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
      |> Enum.flat_map(fn
        {:end_date, value} ->
          [
            {"endDate", value |> DateTime.from_unix!() |> DateTime.to_iso8601()},
            {"accessEndDate", value |> DateTime.from_unix!() |> DateTime.to_iso8601()},
            {"earliestEndDate", value |> DateTime.from_unix!() |> DateTime.to_iso8601()},
            {"autorenewStatus", "NOT_ELIGIBLE"}
          ]

        {:order_id, value} ->
          [{"id", value}]

        {:asset_id, value} ->
          [{"progId", value}]

        {key, value} ->
          [{key |> Atom.to_string() |> camelize(), value}]
      end)
      |> Map.new()

    Map.merge(old_order, order)
  end

  defp transform_order(order) do
    {:ok, end_date, _offset} = DateTime.from_iso8601(order["endDate"])

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
