defmodule ElixirBench.Github do
  require Logger

  @github_client Application.get_env(:elixir_bench, :github_client)

  def fetch_config(repo_owner, repo_name, branch_or_commit) do
    path = [repo_owner, "/", repo_name, "/", branch_or_commit, "/bench/config.yml"]
    slug = "#{repo_owner}/#{repo_name}##{branch_or_commit}"
    Logger.info("Requesting bench config for: #{slug}")
    case @github_client.get_yaml(path) do
      {:ok, config} ->
        {:ok, config}
      {:error, {404, _}} ->
        {:error, :failed_config_fetch}
      {:error, reason} ->
        Logger.error("Failed to fetch config for #{slug}: #{inspect reason}")
        {:error, :failed_config_fetch}
    end
  end
end
