defmodule ElixirBench.BenchmarksTest do
  use ElixirBench.DataCase
  alias ElixirBench.{Benchmarks, Benchmarks.Job}

  import ElixirBenchWeb.TestHelpers
  import ElixirBench.Factory

  describe "create_job/2" do
    test "insert new Job given correct params" do
      repo = insert(:repo)

      assert_difference(Job, 1) do
        Benchmarks.create_job(repo, %{branch_name: "mm/benche", commit_sha: "ABC123"})
      end
    end

    test "return new Job inserted" do
      repo = insert(:repo)

      {:ok, job} = Benchmarks.create_job(repo, %{branch_name: "mm/benche", commit_sha: "ABC123"})
      assert %Job{} = job
    end

    test "return error when missing job attributes" do
      repo = build(:repo)

      {:error, changeset} = Benchmarks.create_job(repo, %{})

      refute changeset.valid?
    end

    test "raise an error when repository is not valid" do
      repo = build(:repo)

      assert_raise Postgrex.Error, fn ->
        Benchmarks.create_job(repo, %{branch_name: "mm/benche", commit_sha: "ABC123"})
      end 
    end
  end

end
