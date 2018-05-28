defmodule ElixirBench.Factory do
  use ExMachina.Ecto, repo: ElixirBench.Repo

  alias ElixirBench.Repos
  alias ElixirBench.Benchmarks.{Benchmark, Measurement, Job, Runner}

  def runner_factory do
    %Runner{
      name: "myrunner",
      api_key: "mykey",
      api_key_hash: Bcrypt.hash_pwd_salt("mykey")
    }
  end

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
      repo: build(:repo),
      uuid: Ecto.UUID.generate()
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

  # This is the kind of data returned by benchee run. This sample has 4
  # benchmarks examples
  def executed_job_fixture() do
    %{
      "elixir_version" => "1.5.2",
      "erlang_version" => "20.1",
      "dependency_versions" => %{},
      "cpu" => "Intel(R) Core(TM) i7-4770HQ CPU @ 2.20GHz",
      "cpu_count" => 8,
      "memory_mb" => 16384,
      "log" => """
      [now] Oh how ward it was to run this benchmark!
      """,
      "measurements" => %{
        "insert_mysql/insert_plain" => %{
          "average" => 393.560253365004,
          "ips" => 2540.906993147397,
          "maximum" => 12453.0,
          "median" => 377.0,
          "minimum" => 306.0,
          "mode" => 369.0,
          "percentiles" => %{"50" => 377.0, "99" => 578.6900000000005},
          "sample_size" => 12630,
          "std_dev" => 209.33476197004862,
          "std_dev_ips" => 1351.5088377210595,
          "std_dev_ratio" => 0.5319001605985423,
          "run_times" => []
        },
        "insert_mysql/insert_changeset" => %{
          "average" => 450.2023723288664,
          "ips" => 2221.2233019276814,
          "maximum" => 32412.0,
          "median" => 397.0,
          "minimum" => 301.0,
          "mode" => 378.0,
          "percentiles" => %{"50" => 397.0, "99" => 1003.3999999999942},
          "sample_size" => 11044,
          "std_dev" => 573.9417528830307,
          "std_dev_ips" => 2831.732735787863,
          "std_dev_ratio" => 1.274852795453007,
          "run_times" => []
        },
        "insert_pg/insert_plain" => %{
          "average" => 473.0912894636744,
          "ips" => 2113.756947699591,
          "maximum" => 13241.0,
          "median" => 450.0,
          "minimum" => 338.0,
          "mode" => 442.0,
          "percentiles" => %{"50" => 450.0, "99" => 727.0},
          "sample_size" => 10516,
          "std_dev" => 273.63253429178945,
          "std_dev_ips" => 1222.5815257169884,
          "std_dev_ratio" => 0.5783926704759165,
          "run_times" => []
        },
        "insert_pg/insert_changeset" => %{
          "average" => 465.8669101807624,
          "ips" => 2146.5357984150173,
          "maximum" => 13092.0,
          "median" => 452.0,
          "minimum" => 338.0,
          "mode" => 440.0,
          "percentiles" => %{"50" => 452.0, "99" => 638.0},
          "sample_size" => 10677,
          "std_dev" => 199.60367678670747,
          "std_dev_ips" => 919.6970816229071,
          "std_dev_ratio" => 0.4284564377179282,
          "run_times" => []
        }
      }
    }
  end
end
