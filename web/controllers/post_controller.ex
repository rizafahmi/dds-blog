defmodule DdsBlog.PostController do
  use DdsBlog.Web, :controller

  def show(conn, %{"slug" => slug}) do
    case DdsBlog.Repo.get_by_slug(slug) do
      {:ok, post} -> render(conn, "show.html", post: post)
      :not_found -> not_found(conn)
    end
  end

  def not_found(conn) do
    conn
    |> put_status(:not_found)
    |> render(DdsBlog.ErrorView, "404.html")
  end
end
