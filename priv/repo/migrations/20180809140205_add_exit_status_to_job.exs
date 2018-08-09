defmodule ElixirBench.Repo.Migrations.AddExitStatusToJob do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :exit_status, :integer, default: nil
    end

    # assume all existent jobs has finished with success
    execute """
    UPDATE jobs SET exit_status = 0 WHERE exit_status IS NULL;
    """, "" # nothing on down
  end
end
