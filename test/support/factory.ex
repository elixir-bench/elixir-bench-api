defmodule ElixirBench.Factory do
  use ExMachina.Ecto, repo: ElixirBench.Repo

  alias ElixirBench.Repos
  alias ElixirBench.Benchmarks.{Benchmark, Measurement, Job}

  def repo_factory do
    %Repos.Repo{
      name: sequence(:name, &"ecto-#{&1}"),
      owner: sequence(:owner, &"elixir-ecto-#{&1}")
    }
  end

  def benchmark_factory do
    %Benchmark{
      name: sequence(:name, &"my_benchmark/scenario-#{&1}"),
      repo: build(:repo)
    }
  end

  def job_factory do
    %Job{
      branch_name: "master",
      commit_sha: sequence(:commit_sha, &"ABCDEF#{&1}"),
      commit_message: "My commit message",
      commit_url: "git.com",
      elixir_version: "1.5.2",
      erlang_version: "20.1",
      repo: build(:repo)
    }
  end

  def measurement_factory do
    repo = insert(:repo)

    job_attrs = %{
      memory_mb: 16384,
      erlang_version: "20.1",
      elixir_version: "1.5.2",
      cpu_count: 8,
      cpu: "Intel(R) Core(TM) i7-4770HQ CPU @ 2.20GHz",
      repo: repo,
      completed_at: DateTime.utc_now()
    }

    %Measurement{
      benchmark: build(:benchmark, repo: repo),
      job: build(:job, job_attrs),
      sample_size: 12630,
      mode: 369.0,
      minimum: 306.0,
      median: 377.0,
      maximum: 12453.0,
      average: 393.560253365004,
      std_dev: 209.33476197004862,
      std_dev_ratio: 0.5319001605985423,
      ips: 2540.906993147397,
      std_dev_ips: 1351.5088377210595,
      run_times: [1.87, 1.44],
      percentiles: %{"50" => 377.0, "99" => 578.6900000000005}
    }
  end
end
