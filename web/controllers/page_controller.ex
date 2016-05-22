defmodule DdsBlog.PageController do
  use DdsBlog.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
