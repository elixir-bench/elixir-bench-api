defmodule ElixirBench.BenchmarksTest do
  use ElixirBench.DataCase
  alias ElixirBench.{Benchmarks, Benchmarks.Job}
  alias ElixirBench.Repos
  import ElixirBenchWeb.TestHelpers
  import ElixirBench.Factory

  describe "create_job/2" do
    test "return a new Job given correct params" do
      repo = insert(:repo)

      assert_difference(Job, 1) do
        Benchmarks.create_job(repo, %{branch_name: "mm/benche", commit_sha: "ABC123"})
      end
    end
  end
end
