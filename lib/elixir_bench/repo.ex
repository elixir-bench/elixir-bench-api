defmodule ElixirBench.Repo do
  use Ecto.Repo, otp_app: :elixir_bench

  def fetch(queryable, opts \\ []) do
    case one(queryable, opts) do
      nil -> {:error, :not_found}
      result -> {:ok, result}
    end
  end

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, config) do
    if config[:load_from_system_env] do
      database_url =
        System.get_env("DATABASE_URL") ||
          raise "expected the DATABASE_URL environment variable to be set"

      {:ok, Keyword.put(config, :url, database_url)}
    else
      {:ok, config}
    end
  end
end
