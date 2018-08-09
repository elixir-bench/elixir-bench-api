defmodule ElixirBench.Repo.Migrations.AddExitStatusToJob do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :exit_status, :integer, default: nil
    end
  end
end
