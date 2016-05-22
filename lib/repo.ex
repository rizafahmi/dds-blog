defmodule DdsBlog.Repo do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def init(:ok) do
    posts = DdsBlog.Crawler.crawl
    {:ok, posts}
  end

  def get_by_slug(slug) do
    GenServer.call(__MODULE__, {:get_by_slug, slug})
  end

  def list do
    GenServer.call(__MODULE__, {:list})
  end

  def handle_call({:get_by_slug, slug}, _from, posts) do
    case Enum.find(posts, fn(x) -> x.slug == slug end) do
      nil -> {:reply, :not_found, posts}
      post -> {:reply, {:ok, post}, posts}
    end
  end

  def handle_call({:list}, _from, posts) do
    {:reply, {:ok, posts}, posts}
  end
end
