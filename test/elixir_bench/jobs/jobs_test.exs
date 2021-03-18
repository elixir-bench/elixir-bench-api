defmodule ElixirBench.JobsTest do
  use ElixirBench.DataCase
  import ElixirBench.Factory
  alias ElixirBench.Benchmarks

  setup do
    Enum.each(0..4, fn _ -> insert(:job) end)
  end

  describe "list_jobs/2" do
    test "returns 2 jobs for page 1" do
      jobs = Benchmarks.list_jobs(1, 2)
      assert length(jobs) == 2
    end

    test "returns 2 jobs for page 2" do
      jobs = Benchmarks.list_jobs(2, 2)
      assert length(jobs) == 2
    end

    test "returns 1 job for page 3" do
      jobs = Benchmarks.list_jobs(3, 2)
      assert length(jobs) == 1
    end

    test "without page returns all 5 jobs" do
      jobs = Benchmarks.list_jobs()
      assert length(jobs) == 5
    end
  end
end
