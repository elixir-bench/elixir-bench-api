defmodule ElixirBench.Repo.Migrations.ChangeModeToArray do
  use Ecto.Migration

  def change do
    alter table(:measurements) do
      remove :mode
      add :mode, {:array, :float}
    end
  end
end
