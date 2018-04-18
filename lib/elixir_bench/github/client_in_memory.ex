defmodule ElixirBench.Github.ClientInMemory do
  @moduledoc """
  The Github InMemory client.

  This client is a mock module to be used in tests.

  This module implements the following functions:

    - a `get_yaml/1` function that takes the url path of the project and return
      a map with mocked data about the raw configuration found in the
      benchee.yml file.
  """

  @behaviour ElixirBench.Github.Client

  def get_yaml(_) do
    {:ok,
      %{
        "deps" => %{
          "docker" => [
            %{
              "container_name" => "postgres",
              "image" => "postgres:9.6.6-alpine"
            },
            %{
              "container_name" => "mysql",
              "environment" => %{
                "MYSQL_ALLOW_EMPTY_PASSWORD" => "true"
              },
              "image" => "mysql:5.7.20"
            }
          ]
        },
        "elixir" => "1.5.2",
        "environment" => %{
          "MYSQL_URL" => "root@localhost",
          "PG_URL" => "postgres:postgres@localhost"
        },
        "erlang" => "20.1.2"
      }
    }
  end
end
