defmodule ElixirBenchWeb.JobViewTest do
  use ElixirBenchWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "render index.json given job without docker dependencies and environment variables" do
    repo = build(:repo, %{owner: "owner", name: "name"})
    job = build(:job, repo: repo)

    %{uuid: uuid, branch_name: branch, commit_sha: commit_sha, config: config} = job
    %{elixir: elixir, erlang: erlang} = config

    %{data: [job_data]} = render(ElixirBenchWeb.JobView, "index.json", %{jobs: [job], repo: repo})

    assert %{
             branch_name: ^branch,
             commit_sha: ^commit_sha,
             config: %{
               deps: %{docker: []},
               elixir_version: ^elixir,
               environment_variables: %{},
               erlang_version: ^erlang
             },
             id: ^uuid,
             repo_slug: "owner/name"
           } = job_data
  end

  test "render index.json given job with docker dependencies" do
    repo = build(:repo)
    job = build(:job, repo: repo) |> with_docker_deps

    %{config: %{deps: %{docker: [dep]}, environment: environment}} = job

    %{container_name: container_name, environment: docker_env, image: image, wait: %{port: port}} =
      dep

    %{data: [job_data]} = render(ElixirBenchWeb.JobView, "index.json", %{jobs: [job], repo: repo})

    assert %{
             environment_variables: ^environment
           } = job_data.config

    assert %{
             container_name: ^container_name,
             environment: ^docker_env,
             image: ^image,
             wait: %{port: ^port}
           } = hd(job_data.config.deps.docker)
  end
end
