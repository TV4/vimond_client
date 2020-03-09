defmodule Vimond.Client.Voucher do
  defmacro __using__(_) do
    quote do
      alias Vimond.Config

      @callback voucher(binary, binary, Config.t()) :: {:ok, map} | {:error, message :: binary}
      def voucher(voucher_code, xff, config = %Config{}) do
        request("voucher", fn ->
          @http_client.get("/api/voucher/#{voucher_code}", headers("X-Forwarded-For": xff), config)
        end)
        |> handle_response(&Vimond.Client.Voucher.extract_voucher/2)
      end
    end
  end

  def extract_voucher(%{"error" => %{"description" => message}}, _header) do
    {:error, %{type: :voucher_invalid, source_errors: [message]}}
  end

  def extract_voucher(voucher, _header) do
    with :ok <- voucher_not_expired(voucher["expiry"]),
         :ok <- voucher_started(voucher["startDate"]),
         :ok <- voucher_has_usages_left(voucher["usages"]),
         :ok <- voucher_has_product(voucher["product"]) do
      {:ok,
       %Vimond.Voucher{
         code: voucher["code"],
         pool: voucher["pool"],
         pool_name: voucher["poolName"],
         product_id: get_in(voucher, ["product", "id"]),
         product_payment_ids: voucher["productPaymentIds"]
       }}
    else
      {:invalid, source_error} ->
        {:error, %{type: :voucher_invalid, source_errors: [source_error]}}
    end
  end

  defp voucher_has_product(nil), do: {:invalid, "Voucher has no product"}
  defp voucher_has_product(_), do: :ok

  defp voucher_has_usages_left(0), do: {:invalid, "Voucher has no more usages"}
  defp voucher_has_usages_left(_), do: :ok

  defp voucher_started(nil), do: :ok

  defp voucher_started(start_date) do
    with {:ok, start_at, _} <- DateTime.from_iso8601(start_date),
         result when result in [:eq, :lt] <- DateTime.compare(start_at, datetime().utc_now()) do
      :ok
    else
      _ -> {:invalid, "Voucher not started"}
    end
  end

  defp voucher_not_expired(nil), do: :ok

  defp voucher_not_expired(expiry) do
    with {:ok, end_at, _} <- DateTime.from_iso8601(expiry),
         :gt <- DateTime.compare(end_at, datetime().utc_now()) do
      :ok
    else
      _ -> {:invalid, "Voucher expired"}
    end
  end

  defp datetime, do: Application.get_env(:vimond_client, :datetime, DateTime)
end
