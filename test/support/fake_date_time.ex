defmodule FakeDateTime do
  def utc_now, do: ~N[2015-09-02 13:24:35] |> DateTime.from_naive!("Etc/UTC")
end
