defmodule ElixirBenchWeb.Github.WebHooks do
  use ElixirBenchWeb, :controller

  alias ElixirBench.{Benchmarks, Repos}

  action_fallback(ElixirBenchWeb.FallbackController)
  @accepted_events ["ping", "push", "pull_request"]

  def handle(conn, params) do
    with {:ok, payload} <- check_payload_params(params),
         {:ok, event} <- validate_event_headers(conn) do
      process_event(event, conn, payload)
    end
  end

  defp process_event("ping", conn, _payload) do
    conn
    |> json(%{message: "pong"})
  end

  defp process_event("pull_request", conn, payload) do
    # data is fetched from sender's repository refered as "head"
    pr_data = get_in(payload, ["pull_request", "head"])

    slug = get_in(pr_data, ["repo", "full_name"])
    branch_name = get_in(pr_data, ["ref"])
    commit_sha = get_in(pr_data, ["sha"])

    with {:ok, %Repos.Repo{} = repo} <- Repos.fetch_repo_by_slug(slug),
         {:ok, job} <-
           Benchmarks.create_job(repo, %{branch_name: branch_name, commit_sha: commit_sha}) do
      conn
      |> render(ElixirBenchWeb.JobView, "show.json", job: job, repo: repo)
    else
      {:error, :invalid_slug} -> {:error, :bad_request}
    end
  end

  defp process_event("push", conn, payload) do
    conn
    |> json(%{event: "push", content: payload})
  end

  defp check_payload_params(params) do
    if p = params["payload"] do
      case Antidote.decode(p) do
        {:ok, payload} ->
          {:ok, payload}

        {:error, _} ->
          {:error, :bad_request}
      end
    else
      {:error, :bad_request}
    end
  end

  defp validate_event_headers(conn) do
    with [event] <- get_req_header(conn, "x-github-event"),
         true <- event in @accepted_events do
      {:ok, event}
    else
      _ -> {:error, :unprocessable_entity}
    end
  end
end
