defmodule TimeConverterTest do
  use ExUnit.Case, async: true
  import TimeConverter

  describe "year_to_iso8601" do
    test "with valid year" do
      assert year_to_iso8601(1970) == "1970-01-01"
    end

    test "handles nil" do
      assert year_to_iso8601(nil) == nil
    end
  end

  describe "iso8601_to_year" do
    test "with valid year" do
      assert iso8601_to_year("1970-01-01T00:00:00Z") == 1970
    end

    test "handles nil" do
      assert iso8601_to_year(nil) == nil
    end
  end
end
