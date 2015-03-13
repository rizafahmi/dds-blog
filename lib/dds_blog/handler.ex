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

  def render_and_generate_response({:ok, file}, params) do

    content = Markdown.to_html file
    title = String.capitalize(params[:param])
    socials = EEx.eval_file "priv/themes/social_buttons.html.eex"
    back = EEx.eval_file "priv/themes/back_button.html.eex"
    comments = EEx.eval_file "priv/themes/comments.html.eex"
    body = EEx.eval_file "priv/themes/index.html.eex",
    [ content: content <> socials <> back <> comments,
      title: title,

    ]
    {:ok, resp} = :cowboy_req.reply(200, params[:headers], body, params[:req])
  end

  def render_and_generate_response({:error, _}, params) do
    content = "Ooopppsss.. The article not found."
    title = "Page not found"
    body = EEx.eval_file "priv/themes/index.html.eex", [content: content, title: title]
    {:ok, resp} = :cowboy_req.reply(404, params[:headers], body, params[:req])
  end

  def get_file("GET", :undefined, req) do
    headers = [{"content-type", "text/html"}]
    contents = "priv/contents/"

    file_lists = File.ls! contents
    # file_lists = Files.Sort.newest(file_lists)
    {files, _} = System.cmd("ls", ["-t", "./priv/contents"])
    file_lists = String.split(files, "\n") |> Enum.filter(fn(item) -> item != "" end)

    content = print_articles file_lists, ""
    title = "Welcome to DDS Blog"
    body = EEx.eval_file "priv/themes/index.html.eex", [content: content, title: title]
    {:ok, _resp} = :cowboy_req.reply(200, headers, body, req)
  end

  def get_file("GET", param, req) do
    headers = [{"content-type", "text/html"}]
    params = %{headers: headers, req: req, param: param}
    file_read = File.read "priv/contents/" <> param <> ".md"
    render_and_generate_response(file_read, params)
  end

  def print_articles([h|t], index_contents) do
    {:ok, article} = File.read "priv/contents/" <> h

    sliced = String.slice article, 0, 1000
    meta = Regex.scan(~r/\<\!\-\-(.*)?\-\-\>/suim, sliced)
    meta_html = meta_generator meta, ""

    marked = Markdown.to_html sliced
    filename = Path.basename(h, ".md")
    more = EEx.eval_file "priv/themes/more_button.html.eex", [filename: filename]
    print_articles t, index_contents <> marked <> more
  end

  def print_articles [], index_contents do
    index_contents
  end

  defp meta_generator [h|t], meta_html do
    meta_generator t, List.flatten [meta_html|h]
  end

  defp meta_generator [], meta_html do
    meta_html
    IO.inspect meta_html
  end

  def terminate(_reason, _req, _state) do
    :ok
  end
end
