defmodule ElixirBench.Github.ClientHTTP do
  @moduledoc """
  The Github HTTP client.

  This client uses HTTP requests to gather data from yml files in given
  repository hosted on Github. It uses the `:hackney` library to actually send
  the requests and the `yamerl` library to decode the data in the yml format.

  Requests follow a base url:

    - base_url = 'https://raw.githubusercontent.com'

  This module implements the following functions:

    - a `get_yaml/1` function that takes the url path of the project and return
      the raw parsed data in the yaml format.
  """

  @behaviour ElixirBench.Github.Client

  def get_yaml(path) do
    get(url(path), [{"accept", "application/yaml"}], &decode_yaml/1)
  end

  @doc false
  defp decode_yaml(content) do
    case :yamerl.decode(content, [:str_node_as_binary, map_node_format: :map]) do
      [parsed] -> {:ok, parsed}
      _ -> {:error, :invalid}
    end
  end

  defp get(url, headers, callback) do
    options = [:with_body, ssl_options: []]

    case :hackney.get(url, headers, <<>>, options) do
      {:ok, 200, _headers, data} ->
        callback.(data)
      {:ok, status, _headers, data} ->
        {:error, {status, data}}
      {:error, error} ->
        {:error, error}
    end
  end

  defp url(path) do
    base_url = 'https://raw.githubusercontent.com'
    Path.join(base_url, path)
  end
end
