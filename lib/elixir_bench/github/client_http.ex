defmodule ElixirBench.Github.ClientHTTP do
  @moduledoc """
  The Github HTTP client.

  This client uses HTTP requests to gather data from yml files in a given
  repository hosted on Github.

  Requests follow the base url: 'https://raw.githubusercontent.com'
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

    case :hackney.get(url, headers, "", options) do
      {:ok, 200, _headers, data} ->
        callback.(data)

      {:ok, status, _headers, data} ->
        {:error, {status, data}}

      {:error, error} ->
        {:error, error}
    end
  end

  defp url(path) do
    Path.join("https://raw.githubusercontent.com", path)
  end
end
