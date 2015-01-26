# Cowboy Tutorial Part 2: Creating Flat File Blog

If you follow ElixirDose blog, we did tried to create a very simple web framework [over here](http://elixirdose.com/post/lets-build-a-web-framework). In that article we did serve some markdown file as the example. In this article, we take the markdown example a little bit further by creating a drop dead simple flat file blogging engine. Because the first article is little bit outdated, we will learn together how to get started with [cowboy](https://github.com/ninenines/cowboy), a small, fast, and modular HTTP server written in Erlang.

Let's talk more detail about blogging engine that we will create. Our blogging engine will read through one folder that have several markdown files. No database whatsoever and it should be blazingly fast as a blog. The idea is to edit your content with your favorite text editor using markdown formatting, then you put on destination folder and viola! You've published your content. Quick and easy. We also support theming if someday we want to redesign the blog.

By creating this blogging engine, we will learn more about certain topics:

* Learn how to serve static files (images, css, javascript) with cowboy,
* Read and convert markdown file into html,
* Dynamically load markdown files depend on URL we requested on browser,
* Add themes and templating.

What we need to accomplish this project is:

* Elixir version 1.0.0 or later,
* Cowboy version 1.0.1,
* ExDoc as markdown tools

Ready, steady, go!

## Creating Elixir Project

We begin our journey by creating elixir project using `mix` tools.

  $> mix new dds_blog --sup

We named our project `dds_blog` after Drop Dead Simple Blogging Engine. And we add `--sup` argument to let `mix` know that we wanted to create an [OTP](http://learnyousomeerlang.com/what-is-otp) supervisor and [OTP](http://learnyousomeerlang.com/what-is-otp) application callback in our main `DdsBlog` module. You may learn more about [OTP here](http://learnyousomeerlang.com/what-is-otp).

Don't forget to change directory to our project folder that we've created.

  $> cd dds_blog

Now's the time to summon the cowboy.

## Add Cowboy To The Project

To make our application running, we'll need a server that can speak HTTP. We will use [Cowboy](https://github.com/ninenines/cowboy) for this case because it's [awesome](http://elixirdose.com/post/lets-build-a-web-framework).

To add Cowboy to our project, simply add Cowboy as the dependency inside `mix.exs` file.

    defp deps do
        {:cowboy, "1.0.0"}
    end

We need also add `:cowboy` under `applications` function while we're editing `mix.exs`.

    def application do
        [applications: [:logger, :cowboy],
        mod: {DdsBlog, []}]
    end

Now run `mix deps.get` to pull all deps needed (Cowboy and it's deps as well).

  $ mix deps.get
  Running dependency resolution
  Unlocked:   cowboy
  Dependency resolution completed successfully
    ranch: v1.0.0
    cowlib: v1.0.1
    cowboy: v1.0.0

  [..]

As you can see, we're pulling not only Cowboy package but also `cowlib` and `ranch` as packages that Cowboy's dependent on.

## Create Cowboy Routes

Ok now we'll create a helper function that defines a set of routes for our project.

    def run do
      routes = [
        {"/", DdsBlog.Handler, []}
      ]

      dispatch = :cowboy_router.compile([{:_, routes}])

      opts = [port: 8000]
      env = [dispatch: dispatch]

      {:ok, _pid} = :cowboy.start_http(:http, 100, opts, [env: env])
    end

Oh yeah, we also calling this `run` function as soon this application started. This
step optional by the way. You still able to run the application but you have to
calling it manually. Then our code bacame something like this:

    defmodule DdsBlog do
      use Application

      def start(_type, _args) do
        import Supervisor.Spec, warn: false

        children = [
          worker(__MODULE, [], function: :run)
        ]

        opts = [strategy: :one_for_one, name: DdsBlog.Supervisor]
        Supervisor.start_link(children, opts)
      end

      def run do
        routes = [
          {"/", DdsBlog.Handler, []}
        ]

        dispatch = :cowboy_router.compile([{:_, routes}])

        opts = [port: 8000]
        env = [dispatch: dispatch]

        {:ok, _pid} = :cowboy.start_http(:http, 100, opts, [env: env])
      end
    end

Now when we run our application, it will respond to all requests to `http://localhost:8000/`.

## Creating Handler

As you can see on the code above, we did pointing out route `"/"` into `DdsBlog.Handler`.
Now we need to create that module to return some responses for any requests received.
Let's create a new file in `lib/dds_blog/handler.ex` and put this code below.


    defmodule DdsBlog.Handler do
      def init({:tcp, :http}, req, opts) do
        headers = [{"content-type", "text/plain"}]
        body = "Hello program!"
        {:ok, resp} = :cowboy_req.reply(200, headers, body, req)
        {:ok, resp, opts}
      end

      def handle(req, state) do
        {:ok, req, state}
      end

      def terminate(_reason, _req, _state) do
        :ok
      end
    end

`init` function doing a lot of works. First, it tells Cowboy of what kind of connectins
we wish to handle (HTTP via TCP). Then we use `:cowboy_req.reply` with status code of 200,
a list of headers, a response body and the request itself.
We will not touch `handle` and `terminate` for now. Let's consider it as boilerplate
code for now.

## Running For The First Time

Now it's the time for us to run this application for the first time.

    $> iex -S mix
    Erlang/OTP 17 [erts-6.2] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

    ==> ranch (compile)
    Compiled src/ranch_transport.erl
    Compiled src/ranch_sup.erl
    Compiled src/ranch_tcp.erl
    Compiled src/ranch_ssl.erl
    Compiled src/ranch_protocol.erl
    Compiled src/ranch_listener_sup.erl
    Compiled src/ranch_app.erl
    Compiled src/ranch_acceptors_sup.erl
    Compiled src/ranch_acceptor.erl
    Compiled src/ranch.erl
    Compiled src/ranch_server.erl
    Compiled src/ranch_conns_sup.erl
    ==> cowlib (compile)
    Compiled src/cow_qs.erl
    Compiled src/cow_spdy.erl
    Compiled src/cow_multipart.erl
    Compiled src/cow_http_te.erl
    Compiled src/cow_http_hd.erl
    Compiled src/cow_date.erl
    Compiled src/cow_http.erl
    Compiled src/cow_cookie.erl
    Compiled src/cow_mimetypes.erl
    ==> cowboy (compile)
    Compiled src/cowboy_sub_protocol.erl
    Compiled src/cowboy_middleware.erl
    Compiled src/cowboy_websocket_handler.erl
    Compiled src/cowboy_sup.erl
    Compiled src/cowboy_static.erl
    Compiled src/cowboy_spdy.erl
    Compiled src/cowboy_router.erl
    Compiled src/cowboy_websocket.erl
    Compiled src/cowboy_protocol.erl
    Compiled src/cowboy_loop_handler.erl
    Compiled src/cowboy_http_handler.erl
    Compiled src/cowboy_rest.erl
    Compiled src/cowboy_handler.erl
    Compiled src/cowboy_clock.erl
    Compiled src/cowboy_bstr.erl
    Compiled src/cowboy_app.erl
    Compiled src/cowboy_http.erl
    Compiled src/cowboy.erl
    Compiled src/cowboy_req.erl
    Compiled lib/dds_blog/handler.ex
    Compiled lib/dds_blog.ex
    Generated dds_blog.app

    Interactive Elixir (1.0.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)>

If didn't add `run` function as a worker child in the supervisor tree, just run in
in the console. Otherwise you should be ok. Open up your browser and pointing out to `http://localhost:8000/` then you'll see
the most beautiful message in the programming world :)

![Hello world](http://i.imgur.com/J1jgiBh.png)

## Static Cowboy

Let's add Cowboy to recognise static files: images, css, javascripts, etc. Everytime
we hit `http://localhost:8000/static/` it will relate to static folders that we will create
shortly. But first, open up `lib/dds_blog.ex` and add one route for static files.

      def run do
        routes = [
          {"/:something", DdsBlog.Handler, []},
          {"/static/[...]", :cowboy_static, {:priv_dir, :dds_blog, "static_files"}}
        ]

        dispatch = :cowboy_router.compile([{:_, routes}])

        opts = [port: 8000]
        env = [dispatch: dispatch]

        {:ok, _pid} = :cowboy.start_http(:http, 100, opts, [env: env])
      end

Don't forget to add `priv/static_files`. All our static files
will be in this directory.

    $> mkdir -p priv/static_files

Re-run `iex -S mix` command and then let's try to add static file inside `static_files`
folder for sanity check. Then try to access it on the browser.

![lily](http://i.imgur.com/ijQEq98.png)


Easy, right?!

## Serve Markdown File

This is where the fun begin. The idea is this: when user entry `http://localhost:8000/some-markdown-file`
our application will look through file named `some-markdown-file.md` inside `priv/contents/` folder,
read through it, convert into html format and return it so the user will received
html contents in their browser as the response.

First thing first, let's change our Cowboy route to accomodate that.

    def run do
      routes = [
        {"/:filename", DdsBlog.Handler, []},
        {"/static/[...]", :cowboy_static, {:priv_dir, :dds_blog, "static_files"}}
      ]

      dispatch = :cowboy_router.compile([{:_, routes}])

      opts = [port: 8000]
      env = [dispatch: dispatch]

      {:ok, _pid} = :cowboy.start_http(:http, 100, opts, [env: env])
    end

This route will accept anything user input in their urls.  Then we also need to change our handler function in `dds_blog/handler.ex`. In Cowboy term, this called [bindings](http://ninenines.eu/docs/en/cowboy/1.0/manual/cowboy_req/index.html#bindings). At first, I though it's [query strings](http://ninenines.eu/docs/en/cowboy/1.0/manual/cowboy_req/index.html#qs_vals), but I was wrong.
[Query]() will accept `http://localhost:8000/?query=yes` kind of format. But we want
to achieve `http://localhost:8000/some-file` so we use [bindings](http://ninenines.eu/docs/en/cowboy/1.0/manual/cowboy_req/index.html#bindings).

Now let's open `lib/dds_blog/handler.ex` and we will handle file that requested by user via urls.
But first we open just one markdown file for sanity check, as usual.

    def init({:tcp, :http}, req, opts) do
      {:ok, req, opts}
    end

    def handle(req, state) do
      {method, req} = :cowboy_req.method(req)
      {param, req} = :cowboy_req.binding(:filename, req)
      IO.inspect param
      {:ok, req} = get_file(method, param, req)
      {:ok, req, state}
    end

    def get_file("GET", :undefined, req) do
      headers = [{"content-type", "text/plain"}]
      body = "Ooops. Article not exists!"
      {:ok, resp} = :cowboy_req.reply(200, headers, body, req)
    end

    def get_file("GET", param, req) do
      headers = [{"content-type", "text/html"}]
      {:ok, file} = File.read "priv/contents/filename.md"
      body = file
      {:ok, resp} = :cowboy_req.reply(200, headers, body, req)
    end

And then we put some markdown file, just rename it to `filename.md` and put it to
`priv/contenst` folder. Make it if the folder doesn't exist yet.
What we've done is first we do use `:cowboy.bindings` to get a filename from
urls. Then we passed the parameter into helper function called `get_file`.
`get_file` function have two type: one with parameter and one more without parameter (a.k.a `:undefined` parameter).
If user didn't include filename in the url, our app will call `get_file` `:undefined`
 and return message "Article doesn't exist". Otherwise, it will call 
`get_file` with `param`.
After the app received parameter, it will read a file we put inside `priv/contents`
directory, for this moment, we just read the exact file called `filename.md`.
Then we print it as response to the user.

![Markdown raw](http://i.imgur.com/NHq0fHP.png)

It prints out markdown as raw. To make it return html we need to convert markdown 
to html first. To do that, we need a package to handle that. Add `markdown` package into `mix.exs` file.

    defp deps do
      [
        {:cowboy, "1.0.0"},
        {:markdown, github: "devinus/markdown"}
      ]
    end

Then get the dependencies with `mix`.

    $> mix deps.get

After that, now we can access `Markdown` module and use `to_html` to convert markdown into
html format. Let's do that now in `lib/dds_blog/handler.ex` file inside `get_file` function.


    def get_file("GET", :undefined, req) do
      headers = [{"content-type", "text/plain"}]
      body = "Ooops. Article not exists!"
      {:ok, resp} = :cowboy_req.reply(200, headers, body, req)
    end

    def get_file("GET", param, req) do
      headers = [{"content-type", "text/html"}]
      {:ok, file} = File.read "priv/contents/filename.md"
      body = Markdown.to_html file
      {:ok, resp} = :cowboy_req.reply(200, headers, body, req)
    end

That's it! Quit and restart `iex -S mix` and refersh your browser. It's html now.

![Imgur](http://i.imgur.com/hZwprG6.png)


Very cool! Ok, let's take a break. It's exhausting...

![meme](http://i.imgur.com/b6H4wKI.jpg)


Now, get back to work!! We need to read the `param` variable and load
markdown file inside `priv/contents/` directory. To do that
we just use concatenate string then read the file. After file loaded,
we convert it into html then return it.


    def get_file("GET", :undefined, req) do
      headers = [{"content-type", "text/plain"}]
      body = "Ooops. Article not exists!"
      {:ok, resp} = :cowboy_req.reply(200, headers, body, req)
    end

    def get_file("GET", param, req) do
      headers = [{"content-type", "text/html"}]
      {:ok, file} = File.read "priv/contents/" <> param <> ".md"
      body = Markdown.to_html file
      {:ok, resp} = :cowboy_req.reply(200, headers, body, req)
    end

Let's copy one more markdown file into `priv/contents/` folder then restart
the `iex -S mix` command. Then we call the file from the browser.
We copy file called `basicfp.md` and calling it with `http://localhost:8000/basicfp`. And, viola!

![basicfp](http://i.imgur.com/K5gT0Y7.png)

Really cool, right?!

Now we need index page. Index page will show you a glipse of all contents we have. We need to iterate through `priv/contents` folder, we get all markdown file then we print it in the index file.


    def get_file("GET", :undefined, req) do
      headers = [{"content-type", "text/html"}]
      file_lists = File.ls! "priv/contents/"
      content = print_articles file_lists, ""
      {:ok, resp} = :cowboy_req.reply(200, headers, content, req)
    end

    def get_file("GET", param, req) do
      headers = [{"content-type", "text/html"}]
      {:ok, file} = File.read "priv/contents/" <> param <> ".md"
      body = Markdown.to_html file
      {:ok, resp} = :cowboy_req.reply(200, headers, body, req)
    end


    def print_articles [h|t], index_contents do
      {:ok, article} = File.read "priv/contents/" <> h
      sliced = String.slice article, 0, 1000
      marked = Markdown.to_html sliced
      filename = String.slice(h, 0, String.length(h) - 3)
      more = "<a class='button' href='#{filename}'>More</a><hr />"
      print_articles t, index_contents <> marked <> more
    end

    def print_articles [], index_contents do
      index_contents
    end

When the routes didn't received any param, we will print index page. We show all the files inside `priv/contents` using the power of functional programming: recursive. Take a look at two `print_articles` function. First of we start the recursive by calling `print_articles` function with list of files we've got from `File.ls` command followed by empty string. `print_articles` will loop through (read file and concatenate) all files until it reached an empty list then it will call the second `print_articles` function that simply do the termination point of the recursive. Then we also did truncated it so it's not too long and also we add more button linked to full article.

Re-run `iex -S mix` command and let check if it's worked. Now pointing out our browser to `http://localhost:8000/` and we will see all the articles, truncated and with `More` button followed with `<hr />` tag. Very nice, right?!

![truncated](http://i.imgur.com/Y29KOT1.png)

And if you click `More`, the link also working well, redirect us into full article view.

> If you noticed, the markdown file didn't truncated properly. If you know how to truncated markdown properly, please let me know.


## Templates And Themes

When you view source our page, both index page or detail page, it will prints out markdown file immedietely so the page is not html format properly. We need to taken care of it by prints out the markdown content inside some divs. This is what we will do now, includes adding some css framework to make our page beauty.

We will use [Skeleton, a responsive css boilerplate](http://getskeleton.com/). You free to use any other css framework out there. Download the css files, and images (and or javascript as well, if includes in the framework) then copy it into our static file directory `priv/static_files`.

    priv/static_files/
    ├── css
    │   ├── normalize.css
    │   └── skeleton.css
    └── images
        └── favicon.png


We also create new folder `priv/themes` to put our template file there. Let's add one file called `index.html.eex`. Notice that we add `eex` extension to html file because we want to binds some variables to the html file using `EEx` templating engine provided by Elixir.

    priv/themes/
    └── index.html.eex

Now we edit that `index.html.eex` file and replace static file url.to meet our Cowboy static url settings.


    <!DOCTYPE html>
    <html lang="en">
    <head>

      <!-- Basic Page Needs
      –––––––––––––––––––––––––––––––––––––––––––––––––– -->
      <meta charset="utf-8">
      <title><%= title %></title>
      <meta name="description" content="">
      <meta name="author" content="">

      <!-- Mobile Specific Metas
      –––––––––––––––––––––––––––––––––––––––––––––––––– -->
      <meta name="viewport" content="width=device-width, initial-scale=1">

      <!-- FONT
      –––––––––––––––––––––––––––––––––––––––––––––––––– -->
      <link href="//fonts.googleapis.com/css?family=Raleway:400,300,600" rel="stylesheet" type="text/css">

      <!-- CSS
      –––––––––––––––––––––––––––––––––––––––––––––––––– -->
      <link rel="stylesheet" href="/static/css/normalize.css">
      <link rel="stylesheet" href="/static/css/skeleton.css">

      <!-- Favicon
      –––––––––––––––––––––––––––––––––––––––––––––––––– -->
      <link rel="icon" type="image/png" href="static/images/favicon.png">

    </head>
    <body>

      <!-- Primary Page Layout
      –––––––––––––––––––––––––––––––––––––––––––––––––– -->
      <div class="container">
        <div class="row">
          <%= content %>
        </div>
      </div>

    <!-- End Document
      –––––––––––––––––––––––––––––––––––––––––––––––––– -->
    </body>
    </html>

As you can see, we also adding `<%= content %>` to bind content variable inside our `container>row` divs. Then we can compile the `eex` file and return html inside our `handler.ex` file. Let's do that right now. We also add `<%= title %>` to add html title changes if we move through pages.

    def get_file("GET", :undefined, req) do
      headers = [{"content-type", "text/html"}]
      file_lists = File.ls! "priv/contents/"
      content = print_articles file_lists, ""
      title = "Welcome to DDS Blog"
      body = EEx.eval_file "priv/themes/index.html.eex", [content: content, title: title]
      {:ok, resp} = :cowboy_req.reply(200, headers, body, req)
    end

    def get_file("GET", param, req) do
      headers = [{"content-type", "text/html"}]
      {:ok, file} = File.read "priv/contents/" <> param <> ".md"
      content = Markdown.to_html file
      title = String.capitalize(param)
      body = EEx.eval_file "priv/themes/index.html.eex", [content: content, title: title]
      {:ok, resp} = :cowboy_req.reply(200, headers, body, req)
    end


That's it! Restart the `iex -S mix` command and see what happen in your browser by refresh it.

![Beauty](http://i.imgur.com/qlSIW6w.png)

If we click More button we also see one beautiful detail page. We're pretty much finish here, but before we warp up, let's add a header, footer and make More button more appealing to click.

Let's do the More button first. Just add class `button button-primary` to the `a` tag.

    def print_articles [h|t], index_contents do
      {:ok, article} = File.read "priv/contents/" <> h
      sliced = String.slice article, 0, 1000
      marked = Markdown.to_html sliced
      filename = String.slice(h, 0, String.length(h) - 3)
      more = "<a class='button button-primary' href='#{filename}'>More</a><hr />"
      print_articles t, index_contents <> marked <> more
    end

We should refactor this thing a little bit. By moving out the html thingy to themes folder then we just eval `eex` into `more` variable.

    def print_articles [h|t], index_contents do
      {:ok, article} = File.read "priv/contents/" <> h
      sliced = String.slice article, 0, 1000
      marked = Markdown.to_html sliced
      filename = String.slice(h, 0, String.length(h) - 3)
      more = EEx.eval_file "priv/themes/more_button.html.eex", [filename: filename]
      print_articles t, index_contents <> marked <> more
    end

And now we create new template named `priv/themes/more_button.html.eex` wit just one
line of button and `hr` tag. Then we will binding a filename into that.

    <a class='button button-primary' href='<%= filename %>'>More</a><hr />

Refresh the browser, just to see everything is ok. And we're done.

## Conclusion

We did a great job pulling it out together this simple flat file blogging engine.
Now we realize how powerfull it is Elixir was.
We built this engine just use two packages: `Cowboy` and `markdown`.
How cool is that?!
I know, I know, some portion of the code maybe a little be naive but we finish
our mission and that's the important thing, right?! We can always improve anything else later.

This is the [full code](https://github.com/rizafahmi/dds-blog). You can always send us
some issues and pull request there for inputs, feedbacks and some contributions. That's it for me and see you next time!

## References

* http://learnyousomeerlang.com/what-is-otp
* https://github.com/ninenines/cowboy
* http://elixir-lang.org/docs/stable/elixir/
