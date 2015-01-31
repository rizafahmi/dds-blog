defmodule DdsBlog.Handler do
  def init({:tcp, :http}, req, opts) do
    {:ok, req, opts}
  end

  def handle(req, state) do
    {method, req} = :cowboy_req.method(req)
    {param, req} = :cowboy_req.binding(:filename, req)
    {:ok, req} = get_file(method, param, req)
    {:ok, req, state}
  end

  def get_file("GET", :undefined, req) do
    headers = [{"content-type", "text/html"}]
    # file_lists = File.ls! "priv/contents/"
    {files, _} = System.cmd("ls", ["-t", "./priv/contents"])
    file_lists = String.split(files, "\n") |> Enum.filter(fn(item) -> item != "" end)
    content = print_articles file_lists, ""
    title = "Welcome to DDS Blog"
    body = EEx.eval_file "priv/themes/index.html.eex", [content: content, title: title]
    {:ok, _resp} = :cowboy_req.reply(200, headers, body, req)
  end

  def get_file("GET", param, req) do
    headers = [{"content-type", "text/html"}]
    file_read = File.read "priv/contents/" <> param <> ".md"
    case file_read do
      {:ok, file} ->
        content = Markdown.to_html file
        title = String.capitalize(param)
        socials = EEx.eval_file "priv/themes/social_buttons.html.eex"
        back = EEx.eval_file "priv/themes/back_button.html.eex"
        body = EEx.eval_file "priv/themes/index.html.eex",
        [ content: content <> socials <> back,
          title: title,

        ]
        {:ok, resp} = :cowboy_req.reply(200, headers, body, req)
      {:error, _} ->
        content = "Ooopppsss.. The article not found."
        title = "Page not found"
        body = EEx.eval_file "priv/themes/index.html.eex", [content: content, title: title]
        {:ok, resp} = :cowboy_req.reply(404, headers, body, req)

    end
  end

  def print_articles([h|t], index_contents) do
    {:ok, article} = File.read "priv/contents/" <> h
    sliced = String.slice article, 0, 1000
    marked = Markdown.to_html sliced
    filename = String.slice(h, 0, String.length(h) - 3)
    more = EEx.eval_file "priv/themes/more_button.html.eex", [filename: filename]
    print_articles t, index_contents <> marked <> more
  end

  def print_articles [], index_contents do
    index_contents
  end

  def terminate(_reason, _req, _state) do
    :ok
  end
end
