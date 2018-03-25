defmodule ElixirBenchWeb.SchemaTest do
  use ElixirBenchWeb.ConnCase

  alias ElixirBenchWeb.AbsintheHelpers
  alias ElixirBench.Repos

  @repo %{owner: "tallysmartins", name: "ecto"}

  describe "repos query" do
    test "not break when there is no registered repo", context do
      query = """
        repos {
          name
          owner
        }
      """

      json = context.conn
        |> post("/api", AbsintheHelpers.query_skeleton(query))
        |> Map.get(:resp_body)
        |> Antidote.decode

      {:ok, %{"data" => %{"repos" => []}}} = json
    end

    test "return repos list", context do
      {:ok, _} = Repos.create_repo(@repo)
      query = """
        repos {
          name
          owner
          slug
        }
      """

      json_data =
      %{
        "data" => %{
           "repos" => [
             %{
               "name" => "ecto",
               "owner" => "tallysmartins",
               "slug" => "tallysmartins/ecto"
             }
           ]
         }
       }

      {:ok, resp} = context.conn
        |> post("/api", AbsintheHelpers.query_skeleton(query))
        |> Map.get(:resp_body)
        |> Antidote.decode

      assert ^json_data = resp
    end
  end

  describe "repo query" do
    test "fetch repo by slug", context do
      {:ok, _} = Repos.create_repo(@repo)

      query = """
        repo (slug: "tallysmartins/ecto") {
          name
          owner
          slug
        }
      """

      json_data =
      %{
        "data" => %{
           "repo" => %{
             "name" => "ecto",
             "owner" => "tallysmartins",
             "slug" => "tallysmartins/ecto"
           }
         }
       }

      {:ok, resp} = context.conn
        |> post("/api", AbsintheHelpers.query_skeleton(query))
        |> Map.get(:resp_body)
        |> Antidote.decode

      assert ^json_data = resp
    end

    test "not break when repo not found", context do
      query = """
        repo (slug: "Idont/exist") {
          name
        }
      """

      {:ok, resp} = context.conn
        |> post("/api", AbsintheHelpers.query_skeleton(query))
        |> Map.get(:resp_body)
        |> Antidote.decode

      error_message = Enum.at(resp["errors"], 0)

      refute resp["data"]["repo"]
      assert %{"message" => "not_found"} = error_message
    end
  end
end

