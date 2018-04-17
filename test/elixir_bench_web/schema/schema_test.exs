defmodule ElixirBenchWeb.SchemaTest do
  use ElixirBenchWeb.ConnCase

  alias ElixirBenchWeb.AbsintheHelpers
  import ElixirBenchWeb.TestHelpers

  describe "repos query" do
    test "return repos list", context do
      repo = insert(:repo)
      another_repo = insert(:repo)

      query = """
        repos {
          name
          owner
          slug
        }
      """

      json_data = %{
        "data" => %{
          "repos" => [
            %{
              "name" => repo.name,
              "owner" => repo.owner,
              "slug" => "#{repo.owner}/#{repo.name}"
            },
            %{
              "name" => another_repo.name,
              "owner" => another_repo.owner,
              "slug" => "#{another_repo.owner}/#{another_repo.name}"
            }
          ]
        }
      }

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      assert ^json_data = resp
    end

    test "return empty list when there is no repo registered", context do
      query = """
        repos {
          name
          owner
        }
      """

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      assert_empty_response_data(resp, "repos")
    end
  end

  describe "repo query" do
    test "fetch repo by slug", context do
      insert(:repo, %{name: "ecto", owner: "tallysmartins"})

      query = """
        repo (slug: "tallysmartins/ecto") {
          name
          owner
          slug
        }
      """

      json_data = %{
        "data" => %{
          "repo" => %{
            "name" => "ecto",
            "owner" => "tallysmartins",
            "slug" => "tallysmartins/ecto"
          }
        }
      }

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      assert ^json_data = resp
    end

    test "return not found message when repo does not exist", context do
      query = """
        repo (slug: "Idont/exist") {
          name
        }
      """

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      error_message = Enum.at(resp["errors"], 0)

      assert %{"message" => "not_found"} = error_message
    end

    test "return required fields message when missing fields", context do
      required_fields = ["slug"]

      query = """
        repo {
          name
        }
      """

      resp_body =
        context.conn
        |> execute_query(query)
        |> Map.get(:resp_body)

      assert_required_fields_message(resp_body, required_fields)
    end

    test "return slug error message when invalid slug is given", context do
      query = """
        repo (slug: "invalidSlug") {
          name
        }
      """

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      error_message = Enum.at(resp["errors"], 0)

      assert %{"message" => "invalid_slug"} = error_message
    end
  end

  describe "benchmark query" do
    test "fetch benchmark by name and repo slug", context do
      benchmark = insert(:benchmark, %{name: "insert_mysql/insert_plain"})
      repo = benchmark.repo

      query = """
        benchmark (
          repo_slug: "#{repo.owner}/#{repo.name}",
          name: "insert_mysql/insert_plain"
        ) {
          name
        }
      """

      json_data = %{
        "data" => %{
          "benchmark" => %{
            "name" => "insert_mysql/insert_plain"
          }
        }
      }

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      assert ^json_data = resp
    end

    test "return not found message when benchmark does not exist", context do
      insert(:repo, %{name: "kernel", owner: "elixir-lang"})

      query = """
        benchmark (
          repo_slug: "elixir-lang/kernel",
          name: "Idont/exist"
        ) {
          name
        }
      """

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      error_message = Enum.at(resp["errors"], 0)

      assert %{"message" => "not_found"} = error_message
    end

    test "return not found when benchmark repo does not exist", context do
      query = """
        benchmark (
          repo_slug: "Idont/exist",
          name: "insert_mysql/insert_plain"
        ) {
          name
        }
      """

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      error_message = Enum.at(resp["errors"], 0)

      assert %{"message" => "not_found"} = error_message
    end

    test "return required fields message when missing fields", context do
      required_fields = ["repoSlug", "name"]

      query = """
        benchmark {
          name
        }
      """

      resp_body =
        context.conn
        |> execute_query(query)
        |> Map.get(:resp_body)

      assert_required_fields_message(resp_body, required_fields)
    end
  end

  describe "measurement query" do
    test "fetch measurement by id", context do
      measurement = insert(:measurement)
      job = measurement.job

      query = """
        measurement (id: #{measurement.id})
        {
          id
          collectedAt
          commit {
            message
            sha
            url
          }
          environment {
            cpu
            cpuCount
            elixirVersion
            erlangVersion
            memory
          }
          result {
            average
            ips
            maximum
            median
            minimum
            mode
            sampleSize
            stdDev
            stdDevIps
            stdDevRatio
          }
        }
      """

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      json_data = %{
        "data" => %{
          "measurement" => %{
            "id" => "#{measurement.id}",
            "collectedAt" => job.completed_at |> DateTime.to_iso8601(),
            "commit" => %{
              "message" => job.commit_message,
              "sha" => job.commit_sha,
              "url" => job.commit_url
            },
            "environment" => %{
              "cpu" => job.cpu,
              "cpuCount" => job.cpu_count,
              "elixirVersion" => job.elixir_version,
              "erlangVersion" => job.erlang_version,
              "memory" => job.memory_mb
            },
            "result" => %{
              "average" => measurement.average,
              "ips" => measurement.ips,
              "maximum" => measurement.maximum,
              "median" => measurement.median,
              "minimum" => measurement.minimum,
              "mode" => measurement.mode,
              "sampleSize" => measurement.sample_size,
              "stdDev" => measurement.std_dev,
              "stdDevIps" => measurement.std_dev_ips,
              "stdDevRatio" => measurement.std_dev_ratio
            }
          }
        }
      }

      assert ^json_data = resp
    end

    test "return not found message when measurement does not exist", context do
      query = """
        measurement (id: 9999)
        {
          id
          collectedAt
        }
      """

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      error_message = Enum.at(resp["errors"], 0)

      assert %{"message" => "not_found"} = error_message
    end

    test "return required field message when missing fields", context do
      required_fields = ["id"]

      query = """
        measurement {
          id
        }
      """

      resp_body =
        context.conn
        |> execute_query(query)
        |> Map.get(:resp_body)

      assert_required_fields_message(resp_body, required_fields)
    end
  end

  describe "jobs query" do
    test "list all jobs", context do
      jobs_ids =
        insert_list(3, :job)
        |> Enum.map(fn job -> Integer.to_string(job.id) end)

      query = """
        jobs {
          id
        }
      """

      json_data = %{
        "data" => %{
          "jobs" => [
            %{"id" => Enum.at(jobs_ids, 0)},
            %{"id" => Enum.at(jobs_ids, 1)},
            %{"id" => Enum.at(jobs_ids, 2)}
          ]
        }
      }

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      assert ^json_data = resp
    end

    test "return empty list when there is no registered jobs", context do
      query = """
        jobs {
          id
        }
      """

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      assert_empty_response_data(resp, "jobs")
    end
  end

  describe "job query" do
    test "fetch job by id", context do
      job = insert(:job)

      query = """
        job (id: "#{job.id}") {
          id
        }
      """

      json_data = %{
        "data" => %{
          "job" => %{
            "id" => "#{job.id}"
          }
        }
      }

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      assert ^json_data = resp
    end

    test "return not found message when job does not exist", context do
      query = """
        job (id: 9999)
        {
          id
        }
      """

      {:ok, resp} =
        context.conn
        |> execute_query(query)
        |> decode_response_body

      error_message = Enum.at(resp["errors"], 0)

      assert %{"message" => "not_found"} = error_message
    end

    test "return required field message when missing job fields", context do
      required_fields = ["id"]

      query = """
        job {
          id
        }
      """

      resp_body =
        context.conn
        |> execute_query(query)
        |> Map.get(:resp_body)

      assert_required_fields_message(resp_body, required_fields)
    end
  end

  defp execute_query(conn, query) do
    conn
    |> post("/api", AbsintheHelpers.query_skeleton(query))
  end
end
