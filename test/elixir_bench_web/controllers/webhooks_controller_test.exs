defmodule ElixirBenchWeb.WebHooksControllerTest do
  use ElixirBenchWeb.ConnCase, async: false

  import ElixirBenchWeb.TestHelpers

  alias ElixirBench.{Repos.Repo, Benchmarks.Job}

  @github_repo_attrs %{name: "public-repo", owner: "baxterthehacker"}

  describe "handle/2" do
    test "create job given pull request event", context do
      insert(:repo, @github_repo_attrs)
      params = %{"payload" => pull_request_payload()}

      assert_difference(Repo, 0) do
        assert_difference(Job, 1) do
          {:ok, %{"data" => data}} =
            context.conn
            |> set_headers("pull_request")
            |> post("/hooks/handle", params)
            |> decode_response_body
        end
      end

      assert %{"branch_name" => "changes", "repo_slug" => "baxterthehacker/public-repo"} = data
    end

    defp set_headers(conn, event) do
      conn
      |> put_req_header("x-github-event", event)
    end
  end
end
