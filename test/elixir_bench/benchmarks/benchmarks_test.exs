defmodule ElixirBench.BenchmarksTest do
  use ElixirBench.DataCase
  alias ElixirBench.{Benchmarks, Benchmarks.Job}
  alias ElixirBench.Repos

  describe "create_job/2" do
    test "return a new Job given correct params" do
      {:ok, repo} = Repos.create_repo(%{owner: "elixir-ecto", name: "ecto"})
      job_attrs = %{branch_name: "mm/benche", commit_sha: "ABC123"}

      jobs_count = Repo.aggregate(Job, :count, :id)
      assert {:ok, %Job{}} = Benchmarks.create_job(repo, job_attrs)

      new_count = Repo.aggregate(Job, :count, :id)
      assert new_count > jobs_count
    end
  end
end
