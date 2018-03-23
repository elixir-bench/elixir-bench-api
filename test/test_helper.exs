ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(ElixirBench.Repo, :manual)

defmodule ElixirBenchWeb.AbsintheHelpers do
  def query_skeleton(query) do
    %{
      "query" => "query { #{query} }",
      "variables" => "{}"
    }
  end

  def mutation_skeleton(query) do
    %{
      "operationName" => "",
      "query" => "#{query}",
      "variables" => ""
    }
  end
end

