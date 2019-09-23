defmodule ElixirBench.RepoTest do
  alias ElixirBench.Repo
  alias ElixirBench.Benchmarks
  use ElixirBench.DataCase

  defmodule RepoMeasurement do
    use Ecto.Schema
    import Ecto.Changeset

    schema "repo_measurements" do
      field :map_float_percentiles, {:map, :float}
      field :map_percentiles, :map
    end

    @fields [:map_float_percentiles, :map_percentiles]
    def changeset(%RepoMeasurement{} = measurement, attrs) do
      measurement
      |> cast(attrs, @fields)
    end
  end

  defmodule CreateMeasurementMigration do
    use Ecto.Migration

    def change do
      create table(:repo_measurements) do
        add(:map_float_percentiles, {:map, :float})
        add(:map_percentiles, :map)
      end
    end
  end

  # A bug in ecto with {:map, :float} fields
  # See discussions in https://github.com/elixir-ecto/ecto/issues/2637
  # This test will let us know when the bug is fixed in future updates of ecto,
  # after that we can remove this

  test "raise when exponential notation is given to field of type {:map, :float}" do
    :ok = Ecto.Migrator.up(Repo, 0, CreateMeasurementMigration, log: false)
    {value, _} = Float.parse("416500")
    assert ^value = 4.165e5

    percentiles = %{"50" => value, "99" => value}

    changeset =
      RepoMeasurement.changeset(%RepoMeasurement{}, %{"map_float_percentiles" => percentiles})

    assert {:ok, _} = Repo.insert(changeset)

    assert_raise ArgumentError,
                 ~r/cannot load `%{"50" => 416500, "99" => 416500}` as type {:map, :float} for field `map_float_percentiles`/,
                 fn ->
                   Repo.all(RepoMeasurement)
                 end

    :ok = Ecto.Migrator.down(Repo, 0, CreateMeasurementMigration, log: false)
  end

  test "not raise when float notation is given for field of type {:map, :float}" do
    :ok = Ecto.Migrator.up(Repo, 0, CreateMeasurementMigration, log: false)
    percentiles = %{"50" => 4101.0, "99" => 4160.0}

    changeset =
      RepoMeasurement.changeset(%RepoMeasurement{}, %{"map_float_percentiles" => percentiles})

    assert {:ok, measurement} = Repo.insert(changeset)
    ^measurement = Repo.one(RepoMeasurement)

    assert %{"50" => 4101.0, "99" => 4160.0} = measurement.map_float_percentiles
    :ok = Ecto.Migrator.down(Repo, 0, CreateMeasurementMigration, log: false)
  end

  test "not raise when exponential notation is given to field of type :map" do
    :ok = Ecto.Migrator.up(Repo, 0, CreateMeasurementMigration, log: false)
    percentiles = %{"50" => 4.165e5, "99" => 4.165e5}
    changeset = RepoMeasurement.changeset(%RepoMeasurement{}, %{"map_percentiles" => percentiles})
    assert {:ok, _} = Repo.insert(changeset)

    measurement = Repo.one(RepoMeasurement)
    assert %{"50" => 416_500, "99" => 416_500} = measurement.map_percentiles
    :ok = Ecto.Migrator.down(Repo, 0, CreateMeasurementMigration, log: false)
  end
end
