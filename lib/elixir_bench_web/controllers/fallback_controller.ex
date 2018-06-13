defmodule ElixirBenchWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ElixirBenchWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(ElixirBenchWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> render(ElixirBenchWeb.ErrorView, :"400")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(ElixirBenchWeb.ErrorView, :"404")
  end

  def call(conn, {:error, :unprocessable_entity}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(ElixirBenchWeb.ErrorView, :"422")
  end

  def call(conn, {:error, :failed_config_fetch}) do
    conn
    |> put_status(:internal_server_error)
    |> render(ElixirBenchWeb.ErrorView, :"500")
  end
end
