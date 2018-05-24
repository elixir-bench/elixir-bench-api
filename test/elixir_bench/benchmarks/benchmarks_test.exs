defmodule ElixirBench.BenchmarksTest do
  use ElixirBench.DataCase
  alias ElixirBench.{Benchmarks, Benchmarks.Job, Benchmarks.Runner}

  import ElixirBenchWeb.TestHelpers
  import ElixirBench.Factory

  describe "create_runner/1" do
    test "insert new Runner given correct params" do
      assert_difference(Runner, 1) do
        Benchmarks.create_runner(%{name: "myrunner", api_key: "sudo"})
      end
    end

    test "return the new Runner inserted" do
      name = "myrunner"
      api_key = "sudo"

      {:ok, runner} = Benchmarks.create_runner(%{name: name, api_key: api_key})

      assert runner.id
      assert %Runner{name: ^name, api_key: ^api_key} = runner
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
      name = "myrunner"
      api_key = "sudo"

      {:ok, my_runner} = Benchmarks.create_runner(%{name: name, api_key: api_key})

      assert {:ok, runner} = Benchmarks.authenticate_runner(name, api_key)
      assert_map_attr(my_runner, runner, [:name, :api_key_hash])
    end

    test "return error when invalid credentials" do
      name = "myrunner"

      {:ok, runner} = Benchmarks.create_runner(%{name: name, api_key: "mykey"})

      assert {:error, :not_found} = Benchmarks.authenticate_runner(runner.name, "anotherkey")
    end

    test "return error when runner does not exist" do
      assert {:error, :not_found} = Benchmarks.authenticate_runner("IdoNotExist", "")
    end
  end

  describe "fetch_benchmark/2" do
    test "return benchmark given valid params" do
      my_bench = insert(:benchmark)
      {:ok, bench} = Benchmarks.fetch_benchmark(my_bench.repo.id, my_bench.name)

      assert_map_attr(my_bench, bench, [:id, :name, :created_at])
    end

    test "return error if benchmark or repo not found" do
      repo = insert(:repo)

      assert {:error, :not_found} = Benchmarks.fetch_benchmark(repo.id, "")
      assert {:error, :not_found} = Benchmarks.fetch_benchmark(nil, "")
    end
  end

  describe "fetch_measurement/1" do
    test "return measurement given valid id" do
      my_measurement = insert(:measurement)
      {:ok, measurement} = Benchmarks.fetch_measurement(my_measurement.id)

      # FIXME find a way to also compare job and benchmark for given measurement
      assert_map_attr(my_measurement, measurement, [:id, :sample_size, :run_times])

      # This does not work because in `measurement` the attributes job and benchmark
      # are not loaded `#Ecto.Association.NotLoaded`
      # assert_map_attr(my_measurement, measurement, [:id, :job, :benchmark])
    end

    test "return error if measurement not found" do
      assert {:error, :not_found} = Benchmarks.fetch_measurement(nil)
      assert {:error, :not_found} = Benchmarks.fetch_measurement(9999)
    end
  end

  describe "fetch_job/1" do
    test "return job given valid id" do
      my_job = insert(:job)
      {:ok, job} = Benchmarks.fetch_job(my_job.id)

      assert_map_attr(my_job, job, [:id, :branch_name, :commit_message])
    end

    test "return error if job not found" do
      assert {:error, :not_found} = Benchmarks.fetch_job(nil)
      assert {:error, :not_found} = Benchmarks.fetch_job(9999)
    end
  end

  describe "fetch_job_by_uuid/1" do
    test "return job given valid uuid" do
      my_job = insert(:job)
      {:ok, job} = Benchmarks.fetch_job_by_uuid(my_job.uuid)

      assert_map_attr(my_job, job, [:id, :uuid, :branch_name, :commit_message])
    end

    test "return error if job not found" do
      binary_uuid = "99999999-9999-9999-9999-999999999999"
      assert {:error, :not_found} = Benchmarks.fetch_job_by_uuid(nil)
      assert {:error, :not_found} = Benchmarks.fetch_job_by_uuid(binary_uuid)
    end
  end

  describe "create_job/2" do
    test "insert new Job given correct params" do
      repo = insert(:repo)

      assert_difference(Job, 1) do
        Benchmarks.create_job(repo, %{branch_name: "mm/benche", commit_sha: "ABC123"})
      end
    end

    test "return the new Job inserted" do
      repo = insert(:repo)

      {:ok, job} = Benchmarks.create_job(repo, %{branch_name: "mm/benche", commit_sha: "ABC123"})
      assert %Job{} = job
    end

    test "return error when missing job attributes" do
      repo = insert(:repo)

      {:error, changeset} = Benchmarks.create_job(repo, %{})

      refute changeset.valid?
    end

    test "return error when repo is not on databse" do
      repo = build(:repo)

      {:error, changeset} =
        Benchmarks.create_job(repo, %{branch_name: "mm/benche", commit_sha: "ABC123"})

      refute changeset.valid?
    end
  end

  def assert_map_attr(first, second, attr) do
    assert Map.take(first, attr) == Map.take(second, attr)
  end
end
