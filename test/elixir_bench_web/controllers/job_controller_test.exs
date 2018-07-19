defmodule ElixirBenchWeb.JobControllerTest do
  use ElixirBenchWeb.ConnCase, async: false

  import ElixirBenchWeb.TestHelpers

  describe "claim/2" do
    test "respond 404 when there is no job to be claimed", context do
      conn =
        context.conn
        |> authenticate!
        |> post("/runner-api/jobs/claim", %{})

      assert response(conn, 404) =~ "Page not found"
    end

    test "return job data when claimed with success", context do
      %{branch_name: branch, commit_sha: commit_sha, uuid: uuid, repo: repo, config: config} =
        insert(:job)

      %{elixir: elixir, erlang: erlang, environment: env} = config
      repo_slug = "#{repo.owner}/#{repo.name}"

      {:ok, %{"data" => data}} =
        context.conn
        |> authenticate!
        |> post("/runner-api/jobs/claim", %{})
        |> decode_response_body

      assert %{
               "branch_name" => ^branch,
               "commit_sha" => ^commit_sha,
               "config" => %{
                 "deps" => %{"docker" => []},
                 "elixir_version" => ^elixir,
                 "environment_variables" => ^env,
                 "erlang_version" => ^erlang
               },
               "id" => ^uuid,
               "repo_slug" => ^repo_slug
             } = data
    end

    test "return error if runner authentication fails", context do
      resp =
        context.conn
        |> put_req_header("authorization", "Basic " <> Base.encode64("test:test"))
        |> post("/runner-api/jobs/claim", %{})

      assert "401 Unauthorized" = resp.resp_body
    end
  end

  defp authenticate!(conn) do
    %{name: name, api_key: api_key} = insert(:runner)

    conn
    |> put_req_header("authorization", "Basic " <> Base.encode64("#{name}:#{api_key}"))
  end
end
