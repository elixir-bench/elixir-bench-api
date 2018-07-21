defmodule ElixirBench.Repo.Migrations.RemoveRunTimesFromMeasurementsTable do
  use Ecto.Migration

  def change do
    alter table(:measurements) do
      remove :run_times
    end
  end
end
