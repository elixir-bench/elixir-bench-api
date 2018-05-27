defmodule ElixirBench.BenchmarksTest do
  use ElixirBench.DataCase
  alias ElixirBench.{Benchmarks, Repos}
  alias Benchmarks.{Benchmark, Measurement, Job, Runner}

  import ElixirBenchWeb.TestHelpers
  import ElixirBench.Factory

  # number of samples in executed_job_fixture()
  @samples_count 4

  describe "create_runner/1" do
    test "insert new Runner given correct params" do
      assert_difference(Runner, 1) do
        assert {:ok, runner} = Benchmarks.create_runner(%{name: "myrunner", api_key: "sudo"})
        assert %Runner{name: "myrunner", api_key: "sudo"} = runner
      end
    end

    test "return error when wrong params" do
      assert {:error, _} = Benchmarks.create_runner(%{})
      assert {:error, _} = Benchmarks.create_runner(%{name: "name"})
      assert {:error, _} = Benchmarks.create_runner(%{api_key: "api_key"})
      assert {:error, _} = Benchmarks.create_runner(%{name: nil, api_key: nil})
    end
  end

  describe "authenticate_runner/2" do
    test "authenticate with success given valid credentials" do
      Benchmarks.create_runner(%{name: "myrunner", api_key: "sudo"})

      assert {:ok, runner} = Benchmarks.authenticate_runner("myrunner", "sudo")
      assert %{name: "myrunner"} = runner
    end

    test "return error when invalid credentials" do
      {:ok, _} = Benchmarks.create_runner(%{name: "myrunner", api_key: "mykey"})

      assert {:error, :not_found} == Benchmarks.authenticate_runner("myrunner", "anotherkey")
      assert {:error, :not_found} == Benchmarks.authenticate_runner("", "")
    end
  end

  describe "fetch_benchmark/2" do
    test "return benchmark given valid params" do
      %{id: bid, repo: repo, name: name} = insert(:benchmark)
      {:ok, bench} = Benchmarks.fetch_benchmark(repo.id, name)

      assert %Benchmark{id: ^bid, name: ^name} = bench
    end

    test "return error if benchmark not found" do
      %{id: rid} = insert(:repo)

      assert {:error, :not_found} == Benchmarks.fetch_benchmark(rid, "")
      assert {:error, :not_found} == Benchmarks.fetch_benchmark(nil, "")
    end
  end

  describe "fetch_measurement/1" do
    test "return measurement given valid id" do
      %{id: mid} = insert(:measurement)
      {:ok, measurement} = Benchmarks.fetch_measurement(mid)

      assert %Measurement{id: ^mid} = measurement
    end

    test "return error if measurement not found" do
      assert {:error, :not_found} == Benchmarks.fetch_measurement(nil)
      assert {:error, :not_found} == Benchmarks.fetch_measurement(9999)
    end
  end

  describe "fetch_job/1" do
    test "return job given valid id" do
      %{id: jid} = insert(:job)
      {:ok, job} = Benchmarks.fetch_job(jid)

      assert %Job{id: ^jid} = job
    end

    test "return error if job not found" do
      assert {:error, :not_found} == Benchmarks.fetch_job(nil)
      assert {:error, :not_found} == Benchmarks.fetch_job(9999)
    end
  end

  describe "fetch_job_by_uuid/1" do
    test "return job given valid uuid" do
      %{id: jid, uuid: uuid} = insert(:job)
      {:ok, job} = Benchmarks.fetch_job_by_uuid(uuid)

      assert %Job{id: ^jid} = job
    end

    test "return error if job not found" do
      binary_uuid = "99999999-9999-9999-9999-999999999999"

      assert {:error, :not_found} == Benchmarks.fetch_job_by_uuid(nil)
      assert {:error, :not_found} == Benchmarks.fetch_job_by_uuid(binary_uuid)
    end
  end

  describe "create_job/2" do
    test "insert new Job given correct params" do
      repo = insert(:repo)

      assert_difference(Job, 1) do
        assert {:ok, job} =
                 Benchmarks.create_job(repo, %{branch_name: "mm/benchee", commit_sha: "ABC123"})

        assert %Job{branch_name: "mm/benchee", commit_sha: "ABC123"} = job
      end
    end

    test "return error when missing job attributes" do
      repo = insert(:repo)

      assert {:error, changeset} = Benchmarks.create_job(repo, %{})
      refute changeset.valid?
    end

    test "return error when repo is not on databse" do
      assert_raise Postgrex.Error, fn ->
        Benchmarks.create_job(%Repos.Repo{}, %{branch_name: "mm/benche", commit_sha: "ABC123"})
      end
    end
  end

  describe "claim_job/1" do
    test "delegate pending job to registered runner" do
      %{id: jid, claimed_by: nil} = insert(:job)
      %{id: rid} = runner = insert(:runner)

      assert {:ok, job} = Benchmarks.claim_job(runner)
      assert %Job{id: ^jid, claimed_by: ^rid} = job
    end

    test "return error if there is no pending jobs" do
      runner = insert(:runner)

      assert {:error, :not_found} == Benchmarks.claim_job(runner)
    end

    test "return error given invalid runner" do
      assert {:error, :not_found} = Benchmarks.claim_job(%Runner{})
      assert {:error, :not_found} = Benchmarks.claim_job(%Runner{id: 9999})
    end
  end

  describe "submit_job/2" do
    test "save benchmark and measurement given correct results" do
      %{completed_at: nil} = job = insert(:job)

      assert_difference(Benchmarks.Benchmark, @samples_count) do
        assert_difference(Benchmarks.Measurement, @samples_count) do
          assert :ok == Benchmarks.submit_job(job, executed_job_fixture())
        end
      end

      job = ElixirBench.Repo.get(Job, job.id)
      refute job.completed_at == nil
    end

    test "associate benchmarks to the given repo" do
      %{repo: repo} = job = insert(:job)

      Benchmarks.submit_job(job, executed_job_fixture())

      query = Ecto.Query.where(Benchmark, repo_id: ^repo.id)
      assert @samples_count == ElixirBench.Repo.aggregate(query, :count, :id)
    end

    test "do not duplicata benchmark in multiple runs" do
      job = insert(:job)

      assert_difference(Benchmarks.Benchmark, 4) do
        assert_difference(Benchmarks.Measurement, 4) do
          assert :ok == Benchmarks.submit_job(job, executed_job_fixture())
        end
      end

      assert_difference(Benchmarks.Benchmark, 0) do
        assert_difference(Benchmarks.Measurement, 4) do
          assert :ok == Benchmarks.submit_job(job, executed_job_fixture())
        end
      end
    end
  end
end
