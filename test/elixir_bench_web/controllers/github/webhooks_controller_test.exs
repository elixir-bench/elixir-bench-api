defmodule ElixirBenchWeb.Github.WebHooksControllerTest do
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

    test "create job given push event", context do
      insert(:repo, @github_repo_attrs)
      params = %{"payload" => push_payload()}

      assert_difference(Repo, 0) do
        assert_difference(Job, 1) do
          {:ok, %{"data" => data}} =
            context.conn
            |> set_headers("push")
            |> post("/hooks/handle", params)
            |> decode_response_body
        end
      end

      assert %{"branch_name" => "changes", "repo_slug" => "baxterthehacker/public-repo"} = data
    end

    test "validate branch ref name in push events", context do
      insert(:repo, @github_repo_attrs)

      payload = push_payload() |> Jason.decode!()

      refs_head = %{payload | "ref" => "refs/heads/mybranch"}
      empty_string = %{payload | "ref" => ""}
      nil_value = %{payload | "ref" => nil}

      assert_difference(Repo, 0) do
        assert_difference(Job, 1) do
          {:ok, %{"data" => data}} =
            context.conn
            |> set_headers("push")
            |> post("/hooks/handle", %{"payload" => Jason.encode!(refs_head)})
            |> decode_response_body
        end
      end

      assert %{"branch_name" => "mybranch", "repo_slug" => "baxterthehacker/public-repo"} = data

      {:ok, %{"errors" => errors}} =
        context.conn
        |> set_headers("push")
        |> post("/hooks/handle", %{"payload" => Jason.encode!(empty_string)})
        |> decode_response_body

      assert %{"branch_name" => ["can't be blank"]} = errors

      {:ok, %{"errors" => errors}} =
        context.conn
        |> set_headers("push")
        |> post("/hooks/handle", %{"payload" => Jason.encode!(nil_value)})
        |> decode_response_body

      assert %{"branch_name" => ["can't be blank"]} = errors
    end

    test "respond to ping event", context do
      response =
        context.conn
        |> set_headers("ping")
        |> post("/hooks/handle", %{"payload" => ~s({"data": "some data"})})

      assert {:ok, %{"message" => "pong"}} = decode_response_body(response)
      assert 200 = response.status
    end

    test "not break given unexpected pull request event payload scheme", context do
      insert(:repo, @github_repo_attrs)
      params = %{"payload" => ~s({"data": "some data"})}

      assert_difference(Repo, 0) do
        assert_difference(Job, 0) do
          {:ok, %{"errors" => errors}} =
            context.conn
            |> set_headers("pull_request")
            |> post("/hooks/handle", params)
            |> decode_response_body
        end
      end

      assert %{"detail" => "Bad request"} = errors
    end

    test "not break given unexpected push event payload scheme", context do
      insert(:repo, @github_repo_attrs)
      params = %{"payload" => ~s({"data": "some data"})}

      assert_difference(Repo, 0) do
        assert_difference(Job, 0) do
          {:ok, %{"errors" => errors}} =
            context.conn
            |> set_headers("push")
            |> post("/hooks/handle", params)
            |> decode_response_body
        end
      end

      assert %{"detail" => "Bad request"} = errors
    end

    test "return error given unprocessable event in header", context do
      insert(:repo, @github_repo_attrs)
      params = %{"payload" => push_payload()}

      {:ok, %{"errors" => errors}} =
        context.conn
        |> set_headers("randomevent")
        |> post("/hooks/handle", params)
        |> decode_response_body

      assert %{"detail" => "Unprocessable entity"} = errors
    end

    test "return error when event headers not present", context do
      insert(:repo, @github_repo_attrs)
      params = %{"payload" => push_payload()}

      {:ok, %{"errors" => errors}} =
        context.conn
        |> post("/hooks/handle", params)
        |> decode_response_body

      assert %{"detail" => "Unprocessable entity"} = errors
    end

    test "return error when payload missing", context do
      insert(:repo, @github_repo_attrs)

      {:ok, %{"errors" => errors}} =
        context.conn
        |> set_headers("pull_request")
        |> post("/hooks/handle", %{"payload" => ""})
        |> decode_response_body

      assert %{"detail" => "Bad request"} = errors

      {:ok, %{"errors" => errors}} =
        context.conn
        |> set_headers("pull_request")
        |> post("/hooks/handle")
        |> decode_response_body

      assert %{"detail" => "Bad request"} = errors
    end
  end

  defp set_headers(conn, event) do
    conn
    |> put_req_header("x-github-event", event)
  end
end
