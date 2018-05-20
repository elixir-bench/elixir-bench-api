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

defmodule ElixirBenchWeb.TestHelpers do
  @moduledoc false

  import ExUnit.Assertions

  def assert_required_fields_message(resp_body, required_fields) do
    Enum.map(required_fields, fn field ->
      assert(
        required_field_message_in_string?(field, resp_body),
        "Error message not found for field \"#{field}\" in #{resp_body}"
      )
    end)
  end

  def assert_empty_response_data(response, query) do
    json_data = %{
      "data" => %{
        query => []
      }
    }

    assert json_data == response
  end

  # This function follows the Absinthe error message pattern and can break if
  # this pattern changes in future versions. Therefore it should be used inside
  # another assertive function like in assert_required_fields/2
  defp required_field_message_in_string?(field, response) do
    response =~ ~r/In argument \\\"#{field}\\\": Expected type .*, found null/
  end
end
