defmodule ElixirBench.Benchmarks.Measurement do
  use Ecto.Schema
  import Ecto.Changeset
  alias ElixirBench.Benchmarks.{Benchmark, Job, Measurement}

  schema "measurements" do
    belongs_to(:benchmark, Benchmark)
    belongs_to(:job, Job)

    field :sample_size, :integer
    field :mode, {:array, :float}
    field :minimum, :float
    field :median, :float
    field :maximum, :float
    field :average, :float
    field :std_dev, :float
    field :std_dev_ratio, :float

    field :ips, :float
    field :std_dev_ips, :float

    field :percentiles, {:map, :float}

    timestamps(type: :utc_datetime)
  end

  @fields [
    :sample_size,
    :minimum,
    :median,
    :maximum,
    :average,
    :std_dev,
    :std_dev_ratio,
    :ips,
    :std_dev_ips,
    :percentiles
  ]

  @required_fields @fields -- [:mode]

  @doc false
  def changeset(%Measurement{} = measurement, attrs) do
    measurement
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> set_mode(attrs)
  end

  # Benchee can return a uniq value for mode so we need to make it an array
  defp set_mode(changeset, attrs) do
    mode = get_in(attrs, ["mode"])

    mode =
      cond do
        is_integer(mode) or is_float(mode) ->
          [mode]

        true ->
          mode
      end

    cast(changeset, %{mode: mode}, [:mode])
  end
end
