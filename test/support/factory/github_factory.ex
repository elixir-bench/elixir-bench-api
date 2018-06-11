defmodule ElixirBench.GithubFactory do
  @fixtures_dir "test/support/fixtures"

  # Returns the payload of a pull request activity in a given repository.
  # Payload example is read from fixtures/pull_request.json and was copied from
  # https://developer.github.com/v3/activity/events/types/#pullrequestevent
  def pull_request_payload() do
    case read_file("pull_request.json") do
      {:ok, data} -> data
      {:error, _} -> ""
    end
  end

  def read_file(file) do
    Path.join(@fixtures_dir, file)
    |> File.read()
  end
end
