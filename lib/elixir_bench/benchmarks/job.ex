defmodule ElixirBench.Benchmarks.Job do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2, where: 2]

  alias ElixirBench.Repos
  alias ElixirBench.Repo
  alias ElixirBench.Benchmarks.{Runner, Job, Config}

  schema "jobs" do
    field :uuid, :binary_id

    belongs_to(:repo, Repos.Repo)
    belongs_to(:claimant, Runner, foreign_key: :claimed_by)
    field :claimed_at, :utc_datetime
    field :completed_at, :utc_datetime
    field :log, :string
    field :exit_status, :integer

    field :branch_name, :string
    field :commit_message, :string
    field :commit_sha, :string
    field :commit_url, :string

    field :cpu, :string
    field :cpu_count, :integer
    field :dependency_versions, {:map, :string}
    field :elixir_version, :string
    field :erlang_version, :string
    field :memory_mb, :integer
    field :claim_count, :integer, default: 0

    embeds_one(:config, Config)

    timestamps()
  end

  @max_retries Confex.fetch_env!(:elixir_bench, :job_max_retries)

  @submit_fields [
    :elixir_version,
    :erlang_version,
    :dependency_versions,
    :cpu,
    :cpu_count,
    # TODO: change to a string memory
    # :memory_mb,
    :log,
    :exit_status
  ]

  @create_fields [
    :branch_name,
    :commit_sha
  ]

  def claim_changeset(%Job{} = job, claimed_by) do
    job
    |> change(claimed_by: claimed_by, claimed_at: DateTime.utc_now())
    |> change(claim_count: job.claim_count + 1)

    # |> prepare_changes(&increment_claim_count/1)
  end

  def create_changeset(%Job{} = job, attrs) do
    job
    |> cast(attrs, @create_fields)
    |> validate_required(@create_fields)
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  def submit_changeset(%Job{} = job, attrs) do
    job
    |> cast(attrs, @submit_fields)
    |> validate_required(@submit_fields)
    |> put_change(:completed_at, DateTime.utc_now())
  end

  def filter_by_repo(query, repo_id) do
    from(j in query, where: j.repo_id == ^repo_id)
  end

  def claimable(query) do
    from(j in query, where: j.claim_count < @max_retries)
  end

  defp increment_claim_count(changeset) do
    Job
    |> where(id: ^changeset.data.id)
    |> Repo.update_all(inc: [claim_count: 1])

    changeset
  end
end
