defmodule MeasurementTest do
  alias ElixirBench.Benchmarks.Measurement
  use ElixirBench.DataCase

  @attrs %{
    "average" => 465.8669101807624,
    "ips" => 2146.5357984150173,
    "maximum" => 13092.0,
    "median" => 452.0,
    "minimum" => 338.0,
    "percentiles" => %{"50" => 452.0, "99" => 638.0},
    "run_times" => [],
    "sample_size" => 10677,
    "std_dev" => 199.60367678670747,
    "std_dev_ips" => 919.6970816229071,
    "std_dev_ratio" => 0.4284564377179282,
    "mode" => nil
  }

  describe "changeset/2" do
    test "cast required fields" do
      changeset = Measurement.changeset(%Measurement{}, @attrs)

      assert changeset.valid?

      assert [
               :average,
               :ips,
               :maximum,
               :median,
               :minimum,
               :percentiles,
               :run_times,
               :sample_size,
               :std_dev,
               :std_dev_ips,
               :std_dev_ratio
             ] = Map.keys(changeset.changes)
    end

    test "format and validade mode values" do
      changeset = Measurement.changeset(%Measurement{}, %{@attrs | "mode" => ""})

      assert changeset.valid?
      refute Map.has_key?(changeset.changes, :mode)

      changeset = Measurement.changeset(%Measurement{}, %{@attrs | "mode" => nil})

      assert changeset.valid?
      refute Map.has_key?(changeset.changes, :mode)

      changeset = Measurement.changeset(%Measurement{}, %{@attrs | "mode" => 1})

      assert changeset.valid?
      assert [1.0] = changeset.changes.mode

      changeset = Measurement.changeset(%Measurement{}, %{@attrs | "mode" => 1.2})

      assert changeset.valid?
      assert [1.2] = changeset.changes.mode

      changeset = Measurement.changeset(%Measurement{}, %{@attrs | "mode" => [1.2, 1.4]})

      assert changeset.valid?
      assert [1.2, 1.4] = changeset.changes.mode

      changeset = Measurement.changeset(%Measurement{}, %{@attrs | "mode" => [1.2, "1.4"]})

      assert changeset.valid?
      assert [1.2, 1.4] = changeset.changes.mode

      changeset = Measurement.changeset(%Measurement{}, %{@attrs | "mode" => "str"})

      refute changeset.valid?
      refute Map.has_key?(changeset.changes, :mode)
      assert [mode: {"is invalid", _}] = changeset.errors

      changeset = Measurement.changeset(%Measurement{}, %{@attrs | "mode" => ["str"]})

      refute changeset.valid?
      refute Map.has_key?(changeset.changes, :mode)
      assert [mode: {"is invalid", _}] = changeset.errors
    end
  end
end
