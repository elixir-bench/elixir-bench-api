defmodule ElixirBench.Github.Client do
  @moduledoc """
  The Github client specification.

  This module defines an interface for writing Github clients. The
  clients provide the api to get the raw configuration based on the
  benchee.yml file of the target repository. Their implementation can follow
  different protocol interfaces, like the `ElixirBench.Github.ClientHTTP`
  module or a client can be defined with testing pourposes, to be used as mock,
  like in `ElixirBench.Github.ClientInMemory`.
  """

  @callback get_yaml(path :: String.t()) :: {:ok, config :: Map.t()} | {:error, reason :: term}
end
