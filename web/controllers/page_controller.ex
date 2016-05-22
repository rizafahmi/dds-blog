defmodule DdsBlog.PageController do
  use DdsBlog.Web, :controller

  def index(conn, _params) do
    {:ok, posts} = DdsBlog.Repo.list()
    render conn, "index.html", posts: posts
  end
end
