defmodule ElixirBench.BenchmarksTest do
  use ElixirBench.DataCase
  alias ElixirBench.{Benchmarks, Benchmarks.Job}
  alias ElixirBench.Repos

  describe "when correct params" do
    test "create_job/2 should return new Job" do
      {:ok, repo} = Repos.create_repo(%{owner: "elixir-ecto", name: "ecto"})
      job_attrs = %{branch_name: "mm/benche", commit_sha: "ABC123"}

      jobs_count = ElixirBench.Repo.all(Job) |> length
      assert {:ok, %Job{}} = Benchmarks.create_job(repo, job_attrs)

      new_count = ElixirBench.Repo.all(Job) |> length
      assert new_count > jobs_count
    end
  end
end
