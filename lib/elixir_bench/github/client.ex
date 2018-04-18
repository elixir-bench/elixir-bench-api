defmodule ElixirBench.Github.Client do
  @moduledoc """
  The Github client specification.

  This module defines an interface for writing Github clients. The
  clients provide the api to get the raw configuration based on the
  benchee.yml file of the target repository. Their implementation can follow
  different protocol interfaces, like the `ElixirBench.Github.ClientHTTP`
  module or a client can be defined with testing pourposes, to be used as mock,
  like in `ElixirBench.Github.ClientInMemory`.

  A module that implements the Github client behaviour must export:

    - a `get_yaml/1` function that takes the url path of the project and returns
    a map with the configuration found in the benchee.yml that is stored
    inside the `benchee directory`.
  """

  @callback get_yaml(path :: String) :: {:ok, config :: Map} | {:error, reason :: term}
end
