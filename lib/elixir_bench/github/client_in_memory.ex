defmodule ElixirBench.Github.ClientInMemory do
  @moduledoc """
  The Github InMemory client.

  This client is a mock module to be used in tests.
  """

  @behaviour ElixirBench.Github.Client

  def get_yaml(_) do
    {:ok,
     %{
       "deps" => %{
         "docker" => [
           %{
             "container_name" => "postgres",
             "wait" => %{port: "123"},
             "image" => "postgres:9.6.6-alpine"
           },
           %{
             "container_name" => "mysql",
             "wait" => %{port: "321"},
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
     }}
  end
end
