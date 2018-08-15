defmodule ElixirBench.Repo.Migrations.AddsClaimsCountToJobs do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :claim_count, :integer, default: 0
    end

    # assume all existent jobs has being claimed once
    execute """
    UPDATE jobs SET claim_count = 1 WHERE claimed_by IS NOT NULL;
    """, "" # nothing on down
  end
end
