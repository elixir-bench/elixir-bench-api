defmodule ElixirBenchWeb.Github.WebHooks do
  use ElixirBenchWeb, :controller

  alias ElixirBench.{Benchmarks, Repos}

  action_fallback(ElixirBenchWeb.FallbackController)
  @accepted_events ["ping", "push", "pull_request"]

  def handle(conn, params) do
    with {:ok, payload} <- check_payload_params(params),
         {:ok, event_name} <- validate_event_headers(conn) do
      event_name
      |> extract_job_attrs(payload)
      |> process_event(conn)
    end
  end

  defp extract_job_attrs("push", payload) do
    slug = get_in(payload, ["repository", "full_name"])
    commit_sha = get_in(payload, ["after"])

    branch_name =
      case get_in(payload, ["ref"]) do
        nil -> nil
        "" -> nil
        name -> String.replace(name, "refs/heads/", "")
      end

    %{slug: slug, branch_name: branch_name, commit_sha: commit_sha}
  end

  defp extract_job_attrs("pull_request", payload) do
    # data is fetched from sender's repository refered as "head"
    slug = get_in(payload, ["pull_request", "head", "repo", "full_name"])
    commit_sha = get_in(payload, ["pull_request", "head", "sha"])
    branch_name = get_in(payload, ["pull_request", "head", "ref"])

    %{slug: slug, branch_name: branch_name, commit_sha: commit_sha}
  end

  defp extract_job_attrs(event, _payload), do: event

  defp process_event(job_data, conn) when is_map(job_data) do
    %{slug: slug, branch_name: branch_name, commit_sha: commit_sha} = job_data

    with {:ok, %Repos.Repo{} = repo} <- Repos.fetch_repo_by_slug(slug),
         {:ok, job} <-
           Benchmarks.get_or_create_job(repo, %{branch_name: branch_name, commit_sha: commit_sha}) do
      conn
      |> render(ElixirBenchWeb.JobView, "show.json", job: job, repo: repo)
    else
      {:error, error} -> handle_errors({:error, error})
    end
  end

  defp process_event(job_data, conn) do
    case job_data do
      "ping" ->
        json(conn, %{message: "pong"})

      _ ->
        handle_errors({:error, :unprocessable_entity})
    end
  end

  defp check_payload_params(params) do
    if p = params["payload"] do
      case Jason.decode(p) do
        {:ok, payload} ->
          {:ok, payload}

        {:error, reason} ->
          handle_errors({:error, reason})
      end
    else
      handle_errors({:error, :bad_request})
    end
  end

  defp validate_event_headers(conn) do
    with [event] <- get_req_header(conn, "x-github-event"),
         true <- event in @accepted_events do
      {:ok, event}
    else
      _ -> handle_errors({:error, :unprocessable_entity})
    end
  end

  defp handle_errors(errors) do
    case errors do
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, :unprocessable_entity} ->
        {:error, :unprocessable_entity}

      _ ->
        {:error, :bad_request}
    end
  end
end
