defmodule TimeConverter do
  def parse_vimond_expires_timestamp(timestamp) do
    timestamp
    |> String.replace("-", " ")
    |> Calendar.DateTime.Parse.httpdate!()
    |> DateTime.to_unix()
  end

  def year_to_iso8601(nil), do: nil
  def year_to_iso8601(year), do: "#{year}-01-01"

  def iso8601_to_year(nil), do: nil

  def iso8601_to_year(date) do
    date
    |> DateTime.from_iso8601()
    |> elem(1)
    |> Map.get(:year)
  end
end
