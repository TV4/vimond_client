defmodule FakeDateTime do
  def utc_now, do: ~N[2015-09-02 13:24:35] |> DateTime.from_naive!("Etc/UTC")

  def tomorrow, do: DateTime.add(FakeDateTime.utc_now(), 24 * 60 * 60, :second)

  def yesterday, do: DateTime.add(FakeDateTime.utc_now(), -24 * 60 * 60, :second)

  def next_year, do: ~N[2016-09-02 13:24:35] |> DateTime.from_naive!("Etc/UTC")
end
