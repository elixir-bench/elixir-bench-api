defmodule ElixirBench.Factory do
  use ExMachina.Ecto, repo: ElixirBench.Repo

  alias ElixirBench.Repos
  alias ElixirBench.Benchmarks.{Benchmark, Measurement, Job, Runner}

  def runner_factory do
    %Runner{
      name: "myrunner",
      api_key: "mykey",
      api_key_hash: Bcrypt.hash_pwd_salt("mykey")
    }
  end

  def repo_factory do
    %Repos.Repo{
      name: sequence(:name, &"ecto-#{&1}"),
      owner: sequence(:owner, &"elixir-ecto-#{&1}")
    }
  end

  def benchmark_factory do
    %Benchmark{
      name: sequence(:name, &"my_benchmark/scenario-#{&1}"),
      repo: build(:repo)
    }
  end

  def job_factory do
    %Job{
      branch_name: "master",
      commit_sha: sequence(:commit_sha, &"ABCDEF#{&1}"),
      commit_message: "My commit message",
      commit_url: "git.com",
      elixir_version: "1.5.2",
      erlang_version: "20.1",
      repo: build(:repo),
      uuid: Ecto.UUID.generate()
    }
  end

  def measurement_factory do
    repo = insert(:repo)

    job_attrs = %{
      memory_mb: 16384,
      erlang_version: "20.1",
      elixir_version: "1.5.2",
      cpu_count: 8,
      cpu: "Intel(R) Core(TM) i7-4770HQ CPU @ 2.20GHz",
      repo: repo,
      completed_at: DateTime.utc_now()
    }

    %Measurement{
      benchmark: build(:benchmark, repo: repo),
      job: build(:job, job_attrs),
      sample_size: 12630,
      mode: 369.0,
      minimum: 306.0,
      median: 377.0,
      maximum: 12453.0,
      average: 393.560253365004,
      std_dev: 209.33476197004862,
      std_dev_ratio: 0.5319001605985423,
      ips: 2540.906993147397,
      std_dev_ips: 1351.5088377210595,
      run_times: [1.87, 1.44],
      percentiles: %{"50" => 377.0, "99" => 578.6900000000005}
    }
  end

  # This is the kind of data returned by benchee run. This sample has 4
  # benchmarks examples
  def executed_job_fixture() do
    %{
      "elixir_version" => "1.5.2",
      "erlang_version" => "20.1",
      "dependency_versions" => %{},
      "cpu" => "Intel(R) Core(TM) i7-4770HQ CPU @ 2.20GHz",
      "cpu_count" => 8,
      "memory_mb" => 16384,
      "log" => """
      [now] Oh how ward it was to run this benchmark!
      """,
      "measurements" => %{
        "insert_mysql/insert_plain" => %{
          "average" => 393.560253365004,
          "ips" => 2540.906993147397,
          "maximum" => 12453.0,
          "median" => 377.0,
          "minimum" => 306.0,
          "mode" => 369.0,
          "percentiles" => %{"50" => 377.0, "99" => 578.6900000000005},
          "sample_size" => 12630,
          "std_dev" => 209.33476197004862,
          "std_dev_ips" => 1351.5088377210595,
          "std_dev_ratio" => 0.5319001605985423,
          "run_times" => []
        },
        "insert_mysql/insert_changeset" => %{
          "average" => 450.2023723288664,
          "ips" => 2221.2233019276814,
          "maximum" => 32412.0,
          "median" => 397.0,
          "minimum" => 301.0,
          "mode" => 378.0,
          "percentiles" => %{"50" => 397.0, "99" => 1003.3999999999942},
          "sample_size" => 11044,
          "std_dev" => 573.9417528830307,
          "std_dev_ips" => 2831.732735787863,
          "std_dev_ratio" => 1.274852795453007,
          "run_times" => []
        },
        "insert_pg/insert_plain" => %{
          "average" => 473.0912894636744,
          "ips" => 2113.756947699591,
          "maximum" => 13241.0,
          "median" => 450.0,
          "minimum" => 338.0,
          "mode" => 442.0,
          "percentiles" => %{"50" => 450.0, "99" => 727.0},
          "sample_size" => 10516,
          "std_dev" => 273.63253429178945,
          "std_dev_ips" => 1222.5815257169884,
          "std_dev_ratio" => 0.5783926704759165,
          "run_times" => []
        },
        "insert_pg/insert_changeset" => %{
          "average" => 465.8669101807624,
          "ips" => 2146.5357984150173,
          "maximum" => 13092.0,
          "median" => 452.0,
          "minimum" => 338.0,
          "mode" => 440.0,
          "percentiles" => %{"50" => 452.0, "99" => 638.0},
          "sample_size" => 10677,
          "std_dev" => 199.60367678670747,
          "std_dev_ips" => 919.6970816229071,
          "std_dev_ratio" => 0.4284564377179282,
          "run_times" => []
        }
      }
    }
  end

  def pull_request_payload() do
    '{
      "action": "opened",
      "number": 1,
      "pull_request": {
        "url": "https://api.github.com/repos/baxterthehacker/public-repo/pulls/1",
        "id": 34778301,
        "html_url": "https://github.com/baxterthehacker/public-repo/pull/1",
        "diff_url": "https://github.com/baxterthehacker/public-repo/pull/1.diff",
        "patch_url": "https://github.com/baxterthehacker/public-repo/pull/1.patch",
        "issue_url": "https://api.github.com/repos/baxterthehacker/public-repo/issues/1",
        "number": 1,
        "state": "open",
        "locked": false,
        "title": "Update the README with new information",
        "user": {
          "login": "baxterthehacker",
          "id": 6752317,
          "avatar_url": "https://avatars.githubusercontent.com/u/6752317?v=3",
          "gravatar_id": "",
          "url": "https://api.github.com/users/baxterthehacker",
          "html_url": "https://github.com/baxterthehacker",
          "followers_url": "https://api.github.com/users/baxterthehacker/followers",
          "following_url": "https://api.github.com/users/baxterthehacker/following{/other_user}",
          "gists_url": "https://api.github.com/users/baxterthehacker/gists{/gist_id}",
          "starred_url": "https://api.github.com/users/baxterthehacker/starred{/owner}{/repo}",
          "subscriptions_url": "https://api.github.com/users/baxterthehacker/subscriptions",
          "organizations_url": "https://api.github.com/users/baxterthehacker/orgs",
          "repos_url": "https://api.github.com/users/baxterthehacker/repos",
          "events_url": "https://api.github.com/users/baxterthehacker/events{/privacy}",
          "received_events_url": "https://api.github.com/users/baxterthehacker/received_events",
          "type": "User",
          "site_admin": false
        },
        "body": "This is a pretty simple change that we need to pull into master.",
        "created_at": "2015-05-05T23:40:27Z",
        "updated_at": "2015-05-05T23:40:27Z",
        "closed_at": null,
        "merged_at": null,
        "merge_commit_sha": null,
        "assignee": null,
        "milestone": null,
        "commits_url": "https://api.github.com/repos/baxterthehacker/public-repo/pulls/1/commits",
        "review_comments_url": "https://api.github.com/repos/baxterthehacker/public-repo/pulls/1/comments",
        "review_comment_url": "https://api.github.com/repos/baxterthehacker/public-repo/pulls/comments{/number}",
        "comments_url": "https://api.github.com/repos/baxterthehacker/public-repo/issues/1/comments",
        "statuses_url": "https://api.github.com/repos/baxterthehacker/public-repo/statuses/0d1a26e67d8f5eaf1f6ba5c57fc3c7d91ac0fd1c",
        "head": {
          "label": "baxterthehacker:changes",
          "ref": "changes",
          "sha": "0d1a26e67d8f5eaf1f6ba5c57fc3c7d91ac0fd1c",
          "user": {
            "login": "baxterthehacker",
            "id": 6752317,
            "avatar_url": "https://avatars.githubusercontent.com/u/6752317?v=3",
            "gravatar_id": "",
            "url": "https://api.github.com/users/baxterthehacker",
            "html_url": "https://github.com/baxterthehacker",
            "followers_url": "https://api.github.com/users/baxterthehacker/followers",
            "following_url": "https://api.github.com/users/baxterthehacker/following{/other_user}",
            "gists_url": "https://api.github.com/users/baxterthehacker/gists{/gist_id}",
            "starred_url": "https://api.github.com/users/baxterthehacker/starred{/owner}{/repo}",
            "subscriptions_url": "https://api.github.com/users/baxterthehacker/subscriptions",
            "organizations_url": "https://api.github.com/users/baxterthehacker/orgs",
            "repos_url": "https://api.github.com/users/baxterthehacker/repos",
            "events_url": "https://api.github.com/users/baxterthehacker/events{/privacy}",
            "received_events_url": "https://api.github.com/users/baxterthehacker/received_events",
            "type": "User",
            "site_admin": false
          },
          "repo": {
            "id": 35129377,
            "name": "public-repo",
            "full_name": "baxterthehacker/public-repo",
            "owner": {
              "login": "baxterthehacker",
              "id": 6752317,
              "avatar_url": "https://avatars.githubusercontent.com/u/6752317?v=3",
              "gravatar_id": "",
              "url": "https://api.github.com/users/baxterthehacker",
              "html_url": "https://github.com/baxterthehacker",
              "followers_url": "https://api.github.com/users/baxterthehacker/followers",
              "following_url": "https://api.github.com/users/baxterthehacker/following{/other_user}",
              "gists_url": "https://api.github.com/users/baxterthehacker/gists{/gist_id}",
              "starred_url": "https://api.github.com/users/baxterthehacker/starred{/owner}{/repo}",
              "subscriptions_url": "https://api.github.com/users/baxterthehacker/subscriptions",
              "organizations_url": "https://api.github.com/users/baxterthehacker/orgs",
              "repos_url": "https://api.github.com/users/baxterthehacker/repos",
              "events_url": "https://api.github.com/users/baxterthehacker/events{/privacy}",
              "received_events_url": "https://api.github.com/users/baxterthehacker/received_events",
              "type": "User",
              "site_admin": false
            },
            "private": false,
            "html_url": "https://github.com/baxterthehacker/public-repo",
            "description": "",
            "fork": false,
            "url": "https://api.github.com/repos/baxterthehacker/public-repo",
            "forks_url": "https://api.github.com/repos/baxterthehacker/public-repo/forks",
            "keys_url": "https://api.github.com/repos/baxterthehacker/public-repo/keys{/key_id}",
            "collaborators_url": "https://api.github.com/repos/baxterthehacker/public-repo/collaborators{/collaborator}",
            "teams_url": "https://api.github.com/repos/baxterthehacker/public-repo/teams",
            "hooks_url": "https://api.github.com/repos/baxterthehacker/public-repo/hooks",
            "issue_events_url": "https://api.github.com/repos/baxterthehacker/public-repo/issues/events{/number}",
            "events_url": "https://api.github.com/repos/baxterthehacker/public-repo/events",
            "assignees_url": "https://api.github.com/repos/baxterthehacker/public-repo/assignees{/user}",
            "branches_url": "https://api.github.com/repos/baxterthehacker/public-repo/branches{/branch}",
            "tags_url": "https://api.github.com/repos/baxterthehacker/public-repo/tags",
            "blobs_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/blobs{/sha}",
            "git_tags_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/tags{/sha}",
            "git_refs_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/refs{/sha}",
            "trees_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/trees{/sha}",
            "statuses_url": "https://api.github.com/repos/baxterthehacker/public-repo/statuses/{sha}",
            "languages_url": "https://api.github.com/repos/baxterthehacker/public-repo/languages",
            "stargazers_url": "https://api.github.com/repos/baxterthehacker/public-repo/stargazers",
            "contributors_url": "https://api.github.com/repos/baxterthehacker/public-repo/contributors",
            "subscribers_url": "https://api.github.com/repos/baxterthehacker/public-repo/subscribers",
            "subscription_url": "https://api.github.com/repos/baxterthehacker/public-repo/subscription",
            "commits_url": "https://api.github.com/repos/baxterthehacker/public-repo/commits{/sha}",
            "git_commits_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/commits{/sha}",
            "comments_url": "https://api.github.com/repos/baxterthehacker/public-repo/comments{/number}",
            "issue_comment_url": "https://api.github.com/repos/baxterthehacker/public-repo/issues/comments{/number}",
            "contents_url": "https://api.github.com/repos/baxterthehacker/public-repo/contents/{+path}",
            "compare_url": "https://api.github.com/repos/baxterthehacker/public-repo/compare/{base}...{head}",
            "merges_url": "https://api.github.com/repos/baxterthehacker/public-repo/merges",
            "archive_url": "https://api.github.com/repos/baxterthehacker/public-repo/{archive_format}{/ref}",
            "downloads_url": "https://api.github.com/repos/baxterthehacker/public-repo/downloads",
            "issues_url": "https://api.github.com/repos/baxterthehacker/public-repo/issues{/number}",
            "pulls_url": "https://api.github.com/repos/baxterthehacker/public-repo/pulls{/number}",
            "milestones_url": "https://api.github.com/repos/baxterthehacker/public-repo/milestones{/number}",
            "notifications_url": "https://api.github.com/repos/baxterthehacker/public-repo/notifications{?since,all,participating}",
            "labels_url": "https://api.github.com/repos/baxterthehacker/public-repo/labels{/name}",
            "releases_url": "https://api.github.com/repos/baxterthehacker/public-repo/releases{/id}",
            "created_at": "2015-05-05T23:40:12Z",
            "updated_at": "2015-05-05T23:40:12Z",
            "pushed_at": "2015-05-05T23:40:26Z",
            "git_url": "git://github.com/baxterthehacker/public-repo.git",
            "ssh_url": "git@github.com:baxterthehacker/public-repo.git",
            "clone_url": "https://github.com/baxterthehacker/public-repo.git",
            "svn_url": "https://github.com/baxterthehacker/public-repo",
            "homepage": null,
            "size": 0,
            "stargazers_count": 0,
            "watchers_count": 0,
            "language": null,
            "has_issues": true,
            "has_downloads": true,
            "has_wiki": true,
            "has_pages": true,
            "forks_count": 0,
            "mirror_url": null,
            "open_issues_count": 1,
            "forks": 0,
            "open_issues": 1,
            "watchers": 0,
            "default_branch": "master"
          }
        },
        "base": {
          "label": "baxterthehacker:master",
          "ref": "master",
          "sha": "9049f1265b7d61be4a8904a9a27120d2064dab3b",
          "user": {
            "login": "baxterthehacker",
            "id": 6752317,
            "avatar_url": "https://avatars.githubusercontent.com/u/6752317?v=3",
            "gravatar_id": "",
            "url": "https://api.github.com/users/baxterthehacker",
            "html_url": "https://github.com/baxterthehacker",
            "followers_url": "https://api.github.com/users/baxterthehacker/followers",
            "following_url": "https://api.github.com/users/baxterthehacker/following{/other_user}",
            "gists_url": "https://api.github.com/users/baxterthehacker/gists{/gist_id}",
            "starred_url": "https://api.github.com/users/baxterthehacker/starred{/owner}{/repo}",
            "subscriptions_url": "https://api.github.com/users/baxterthehacker/subscriptions",
            "organizations_url": "https://api.github.com/users/baxterthehacker/orgs",
            "repos_url": "https://api.github.com/users/baxterthehacker/repos",
            "events_url": "https://api.github.com/users/baxterthehacker/events{/privacy}",
            "received_events_url": "https://api.github.com/users/baxterthehacker/received_events",
            "type": "User",
            "site_admin": false
          },
          "repo": {
            "id": 35129377,
            "name": "public-repo",
            "full_name": "baxterthehacker/public-repo",
            "owner": {
              "login": "baxterthehacker",
              "id": 6752317,
              "avatar_url": "https://avatars.githubusercontent.com/u/6752317?v=3",
              "gravatar_id": "",
              "url": "https://api.github.com/users/baxterthehacker",
              "html_url": "https://github.com/baxterthehacker",
              "followers_url": "https://api.github.com/users/baxterthehacker/followers",
              "following_url": "https://api.github.com/users/baxterthehacker/following{/other_user}",
              "gists_url": "https://api.github.com/users/baxterthehacker/gists{/gist_id}",
              "starred_url": "https://api.github.com/users/baxterthehacker/starred{/owner}{/repo}",
              "subscriptions_url": "https://api.github.com/users/baxterthehacker/subscriptions",
              "organizations_url": "https://api.github.com/users/baxterthehacker/orgs",
              "repos_url": "https://api.github.com/users/baxterthehacker/repos",
              "events_url": "https://api.github.com/users/baxterthehacker/events{/privacy}",
              "received_events_url": "https://api.github.com/users/baxterthehacker/received_events",
              "type": "User",
              "site_admin": false
            },
            "private": false,
            "html_url": "https://github.com/baxterthehacker/public-repo",
            "description": "",
            "fork": false,
            "url": "https://api.github.com/repos/baxterthehacker/public-repo",
            "forks_url": "https://api.github.com/repos/baxterthehacker/public-repo/forks",
            "keys_url": "https://api.github.com/repos/baxterthehacker/public-repo/keys{/key_id}",
            "collaborators_url": "https://api.github.com/repos/baxterthehacker/public-repo/collaborators{/collaborator}",
            "teams_url": "https://api.github.com/repos/baxterthehacker/public-repo/teams",
            "hooks_url": "https://api.github.com/repos/baxterthehacker/public-repo/hooks",
            "issue_events_url": "https://api.github.com/repos/baxterthehacker/public-repo/issues/events{/number}",
            "events_url": "https://api.github.com/repos/baxterthehacker/public-repo/events",
            "assignees_url": "https://api.github.com/repos/baxterthehacker/public-repo/assignees{/user}",
            "branches_url": "https://api.github.com/repos/baxterthehacker/public-repo/branches{/branch}",
            "tags_url": "https://api.github.com/repos/baxterthehacker/public-repo/tags",
            "blobs_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/blobs{/sha}",
            "git_tags_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/tags{/sha}",
            "git_refs_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/refs{/sha}",
            "trees_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/trees{/sha}",
            "statuses_url": "https://api.github.com/repos/baxterthehacker/public-repo/statuses/{sha}",
            "languages_url": "https://api.github.com/repos/baxterthehacker/public-repo/languages",
            "stargazers_url": "https://api.github.com/repos/baxterthehacker/public-repo/stargazers",
            "contributors_url": "https://api.github.com/repos/baxterthehacker/public-repo/contributors",
            "subscribers_url": "https://api.github.com/repos/baxterthehacker/public-repo/subscribers",
            "subscription_url": "https://api.github.com/repos/baxterthehacker/public-repo/subscription",
            "commits_url": "https://api.github.com/repos/baxterthehacker/public-repo/commits{/sha}",
            "git_commits_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/commits{/sha}",
            "comments_url": "https://api.github.com/repos/baxterthehacker/public-repo/comments{/number}",
            "issue_comment_url": "https://api.github.com/repos/baxterthehacker/public-repo/issues/comments{/number}",
            "contents_url": "https://api.github.com/repos/baxterthehacker/public-repo/contents/{+path}",
            "compare_url": "https://api.github.com/repos/baxterthehacker/public-repo/compare/{base}...{head}",
            "merges_url": "https://api.github.com/repos/baxterthehacker/public-repo/merges",
            "archive_url": "https://api.github.com/repos/baxterthehacker/public-repo/{archive_format}{/ref}",
            "downloads_url": "https://api.github.com/repos/baxterthehacker/public-repo/downloads",
            "issues_url": "https://api.github.com/repos/baxterthehacker/public-repo/issues{/number}",
            "pulls_url": "https://api.github.com/repos/baxterthehacker/public-repo/pulls{/number}",
            "milestones_url": "https://api.github.com/repos/baxterthehacker/public-repo/milestones{/number}",
            "notifications_url": "https://api.github.com/repos/baxterthehacker/public-repo/notifications{?since,all,participating}",
            "labels_url": "https://api.github.com/repos/baxterthehacker/public-repo/labels{/name}",
            "releases_url": "https://api.github.com/repos/baxterthehacker/public-repo/releases{/id}",
            "created_at": "2015-05-05T23:40:12Z",
            "updated_at": "2015-05-05T23:40:12Z",
            "pushed_at": "2015-05-05T23:40:26Z",
            "git_url": "git://github.com/baxterthehacker/public-repo.git",
            "ssh_url": "git@github.com:baxterthehacker/public-repo.git",
            "clone_url": "https://github.com/baxterthehacker/public-repo.git",
            "svn_url": "https://github.com/baxterthehacker/public-repo",
            "homepage": null,
            "size": 0,
            "stargazers_count": 0,
            "watchers_count": 0,
            "language": null,
            "has_issues": true,
            "has_downloads": true,
            "has_wiki": true,
            "has_pages": true,
            "forks_count": 0,
            "mirror_url": null,
            "open_issues_count": 1,
            "forks": 0,
            "open_issues": 1,
            "watchers": 0,
            "default_branch": "master"
          }
        },
        "_links": {
          "self": {
            "href": "https://api.github.com/repos/baxterthehacker/public-repo/pulls/1"
          },
          "html": {
            "href": "https://github.com/baxterthehacker/public-repo/pull/1"
          },
          "issue": {
            "href": "https://api.github.com/repos/baxterthehacker/public-repo/issues/1"
          },
          "comments": {
            "href": "https://api.github.com/repos/baxterthehacker/public-repo/issues/1/comments"
          },
          "review_comments": {
            "href": "https://api.github.com/repos/baxterthehacker/public-repo/pulls/1/comments"
          },
          "review_comment": {
            "href": "https://api.github.com/repos/baxterthehacker/public-repo/pulls/comments{/number}"
          },
          "commits": {
            "href": "https://api.github.com/repos/baxterthehacker/public-repo/pulls/1/commits"
          },
          "statuses": {
            "href": "https://api.github.com/repos/baxterthehacker/public-repo/statuses/0d1a26e67d8f5eaf1f6ba5c57fc3c7d91ac0fd1c"
          }
        },
        "merged": false,
        "mergeable": null,
        "mergeable_state": "unknown",
        "merged_by": null,
        "comments": 0,
        "review_comments": 0,
        "commits": 1,
        "additions": 1,
        "deletions": 1,
        "changed_files": 1
      },
      "repository": {
        "id": 35129377,
        "name": "public-repo",
        "full_name": "baxterthehacker/public-repo",
        "owner": {
          "login": "baxterthehacker",
          "id": 6752317,
          "avatar_url": "https://avatars.githubusercontent.com/u/6752317?v=3",
          "gravatar_id": "",
          "url": "https://api.github.com/users/baxterthehacker",
          "html_url": "https://github.com/baxterthehacker",
          "followers_url": "https://api.github.com/users/baxterthehacker/followers",
          "following_url": "https://api.github.com/users/baxterthehacker/following{/other_user}",
          "gists_url": "https://api.github.com/users/baxterthehacker/gists{/gist_id}",
          "starred_url": "https://api.github.com/users/baxterthehacker/starred{/owner}{/repo}",
          "subscriptions_url": "https://api.github.com/users/baxterthehacker/subscriptions",
          "organizations_url": "https://api.github.com/users/baxterthehacker/orgs",
          "repos_url": "https://api.github.com/users/baxterthehacker/repos",
          "events_url": "https://api.github.com/users/baxterthehacker/events{/privacy}",
          "received_events_url": "https://api.github.com/users/baxterthehacker/received_events",
          "type": "User",
          "site_admin": false
        },
        "private": false,
        "html_url": "https://github.com/baxterthehacker/public-repo",
        "description": "",
        "fork": false,
        "url": "https://api.github.com/repos/baxterthehacker/public-repo",
        "forks_url": "https://api.github.com/repos/baxterthehacker/public-repo/forks",
        "keys_url": "https://api.github.com/repos/baxterthehacker/public-repo/keys{/key_id}",
        "collaborators_url": "https://api.github.com/repos/baxterthehacker/public-repo/collaborators{/collaborator}",
        "teams_url": "https://api.github.com/repos/baxterthehacker/public-repo/teams",
        "hooks_url": "https://api.github.com/repos/baxterthehacker/public-repo/hooks",
        "issue_events_url": "https://api.github.com/repos/baxterthehacker/public-repo/issues/events{/number}",
        "events_url": "https://api.github.com/repos/baxterthehacker/public-repo/events",
        "assignees_url": "https://api.github.com/repos/baxterthehacker/public-repo/assignees{/user}",
        "branches_url": "https://api.github.com/repos/baxterthehacker/public-repo/branches{/branch}",
        "tags_url": "https://api.github.com/repos/baxterthehacker/public-repo/tags",
        "blobs_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/blobs{/sha}",
        "git_tags_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/tags{/sha}",
        "git_refs_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/refs{/sha}",
        "trees_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/trees{/sha}",
        "statuses_url": "https://api.github.com/repos/baxterthehacker/public-repo/statuses/{sha}",
        "languages_url": "https://api.github.com/repos/baxterthehacker/public-repo/languages",
        "stargazers_url": "https://api.github.com/repos/baxterthehacker/public-repo/stargazers",
        "contributors_url": "https://api.github.com/repos/baxterthehacker/public-repo/contributors",
        "subscribers_url": "https://api.github.com/repos/baxterthehacker/public-repo/subscribers",
        "subscription_url": "https://api.github.com/repos/baxterthehacker/public-repo/subscription",
        "commits_url": "https://api.github.com/repos/baxterthehacker/public-repo/commits{/sha}",
        "git_commits_url": "https://api.github.com/repos/baxterthehacker/public-repo/git/commits{/sha}",
        "comments_url": "https://api.github.com/repos/baxterthehacker/public-repo/comments{/number}",
        "issue_comment_url": "https://api.github.com/repos/baxterthehacker/public-repo/issues/comments{/number}",
        "contents_url": "https://api.github.com/repos/baxterthehacker/public-repo/contents/{+path}",
        "compare_url": "https://api.github.com/repos/baxterthehacker/public-repo/compare/{base}...{head}",
        "merges_url": "https://api.github.com/repos/baxterthehacker/public-repo/merges",
        "archive_url": "https://api.github.com/repos/baxterthehacker/public-repo/{archive_format}{/ref}",
        "downloads_url": "https://api.github.com/repos/baxterthehacker/public-repo/downloads",
        "issues_url": "https://api.github.com/repos/baxterthehacker/public-repo/issues{/number}",
        "pulls_url": "https://api.github.com/repos/baxterthehacker/public-repo/pulls{/number}",
        "milestones_url": "https://api.github.com/repos/baxterthehacker/public-repo/milestones{/number}",
        "notifications_url": "https://api.github.com/repos/baxterthehacker/public-repo/notifications{?since,all,participating}",
        "labels_url": "https://api.github.com/repos/baxterthehacker/public-repo/labels{/name}",
        "releases_url": "https://api.github.com/repos/baxterthehacker/public-repo/releases{/id}",
        "created_at": "2015-05-05T23:40:12Z",
        "updated_at": "2015-05-05T23:40:12Z",
        "pushed_at": "2015-05-05T23:40:26Z",
        "git_url": "git://github.com/baxterthehacker/public-repo.git",
        "ssh_url": "git@github.com:baxterthehacker/public-repo.git",
        "clone_url": "https://github.com/baxterthehacker/public-repo.git",
        "svn_url": "https://github.com/baxterthehacker/public-repo",
        "homepage": null,
        "size": 0,
        "stargazers_count": 0,
        "watchers_count": 0,
        "language": null,
        "has_issues": true,
        "has_downloads": true,
        "has_wiki": true,
        "has_pages": true,
        "forks_count": 0,
        "mirror_url": null,
        "open_issues_count": 1,
        "forks": 0,
        "open_issues": 1,
        "watchers": 0,
        "default_branch": "master"
      },
      "sender": {
        "login": "baxterthehacker",
        "id": 6752317,
        "avatar_url": "https://avatars.githubusercontent.com/u/6752317?v=3",
        "gravatar_id": "",
        "url": "https://api.github.com/users/baxterthehacker",
        "html_url": "https://github.com/baxterthehacker",
        "followers_url": "https://api.github.com/users/baxterthehacker/followers",
        "following_url": "https://api.github.com/users/baxterthehacker/following{/other_user}",
        "gists_url": "https://api.github.com/users/baxterthehacker/gists{/gist_id}",
        "starred_url": "https://api.github.com/users/baxterthehacker/starred{/owner}{/repo}",
        "subscriptions_url": "https://api.github.com/users/baxterthehacker/subscriptions",
        "organizations_url": "https://api.github.com/users/baxterthehacker/orgs",
        "repos_url": "https://api.github.com/users/baxterthehacker/repos",
        "events_url": "https://api.github.com/users/baxterthehacker/events{/privacy}",
        "received_events_url": "https://api.github.com/users/baxterthehacker/received_events",
        "type": "User",
        "site_admin": false
      },
      "installation": {
        "id": 234
      }
    }'
  end
end
