# Cowboy Tutorial Part 2: Creating Flat File Blog

If you've been following ElixirDose for a while, you know that we tried to create a very simple web framework [over here](http://elixirdose.com/post/lets-build-a-web-framework). In that article, we served some Markdown files as the example. In this article, we take the Markdown example a little bit further by creating a drop dead simple flat file blogging engine. Because the first article is little bit outdated, we will learn together how to get started with [Cowboy](https://github.com/ninenines/cowboy): a small, fast, and modular HTTP server written in Erlang.

Our blogging engine will read through one folder that has several Markdown files. There's no database whatsoever, and it should be blazingly fast as a blog. The idea is to edit your content with your favorite text editor using Markdown formatting, then put it in a destination folder.  That's it; you've published your content. Quick and easy. We also support theming if we ever want to redesign the blog.

In creating this blogging engine, we will learn more about certain topics:

* How to serve static files (images, css, javascript) with Cowboy.
* Read and convert Markdown file into HTML.
* Dynamically load Markdown files based on the URL we requested in the browser.
* Add themes and templating using `EEx` rendering and string manipulation.

What we need to accomplish this project is:

* Elixir version 1.0.0 or later
* Cowboy version 1.0.1
* devinus/markdown

Ready, steady, go!

## Creating the Elixir Project

We begin our journey by creating an Elixir project using the `mix` tools.

  $> mix new dds_blog --sup

We named our project `dds_blog` after "Drop Dead Simple Blogging Engine." And we add the `--sup` argument to let `mix` know that we wanted to create an [OTP](http://learnyousomeerlang.com/what-is-otp) supervisor and [OTP](http://learnyousomeerlang.com/what-is-otp) application callback in our main `DdsBlog` module. You can learn more about [OTP here](http://learnyousomeerlang.com/what-is-otp).

Don't forget to change into the directory of the project folder that we've just created.

  $> cd dds_blog

Now's the time to summon the cowboy.

## Add Cowboy To The Project

To make our application run, we'll need a server that can speak HTTP. We will use [Cowboy](https://github.com/ninenines/cowboy) for this case because it's [awesome](http://elixirdose.com/post/lets-build-a-web-framework).

To add Cowboy to our project, simply add it as the dependency inside the `mix.exs` file.

    defp deps do
        {:cowboy, "1.0.0"}
    end

We must also add `:cowboy` in the the `applications` function in `mix.exs`.

    def application do
        [applications: [:logger, :cowboy],
        mod: {DdsBlog, []}]
    end

Now run `mix deps.get` to pull all deps needed (Cowboy and its dependencies, as well).

  $ mix deps.get
  Running dependency resolution
  Unlocked:   cowboy
  Dependency resolution completed successfully
    ranch: v1.0.0
    cowlib: v1.0.1
    cowboy: v1.0.0

  [..]

As you can see, we're pulling not only Cowboy package but also `cowlib` and `ranch` as packages that Cowboy is dependent on.

## Create Cowboy Routes

Now we'll create a helper function that defines a set of routes for our project.

    def run do
      routes = [
        {"/", DdsBlog.Handler, []}
      ]

      dispatch = :cowboy_router.compile([{:_, routes}])

      opts = [port: 8000]
      env = [dispatch: dispatch]

      {:ok, _pid} = :cowboy.start_http(:http, 100, opts, [env: env])
    end

Oh yeah, we also called this `run` function as soon the application started. This
step is optional, by the way. You will still be able to run the application, but you'd then have to
call it manually. Then our code would become something like this:

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

As you can see on the code above, we pointed the route `"/"` into `DdsBlog.Handler`.
Now we need to create that module to return some responses for any requests received.
Let's create a new file in `lib/dds_blog/handler.ex` and put this code below:


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

The `init` function is doing a lot of work. First, it tells Cowboy what kind of connections
we wish to handle (HTTP via TCP). Then we use `:cowboy_req.reply` with a status code of 200,
a list of headers, a response body, and the request itself.

We will not touch `handle` and `terminate` yet. Let's consider it as boilerplate code for now.

## Running For The First Time

Now it's time for us to run this application for the first time.

    $> iex -S mix
    Erlang/OTP 17 [erts-6.2] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

    ==> ranch (compile)
    Compiled src/ranch_transport.erl
    [...]
    ==> cowlib (compile)
    Compiled src/cow_qs.erl
    Compiled src/cow_spdy.erl
    [...]
    ==> cowboy (compile)
    Compiled src/cowboy_sub_protocol.erl
    Compiled src/cowboy_middleware.erl
    Compiled src/cowboy_websocket_handler.erl
    [...]
    Generated dds_blog.app

    Interactive Elixir (1.0.1) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)>

If you didn't add the `run` function as a worker child in the supervisor tree, just run it in the console. Otherwise you should be ok. Open up your browser and point it to `http://localhost:8000/`. You'll see the most beautiful message in the programming world. :)

![Hello world](http://i.imgur.com/J1jgiBh.png)

## Static Cowboy

Let's add to Cowboy the ability to recognize static files: images, css, javascripts, etc. Every time
we hit `http://localhost:8000/static/`, it will relate the route to static folders that we will create
shortly. But first, open up `lib/dds_blog.ex` and add one route for static files.

      def run do
        routes = [
          {"/static/[...]", :cowboy_static, {:priv_dir, :dds_blog, "static_files"}}
        ]

        dispatch = :cowboy_router.compile([{:_, routes}])

        opts = [port: 8000]
        env = [dispatch: dispatch]

        {:ok, _pid} = :cowboy.start_http(:http, 100, opts, [env: env])
      end

Don't forget to add `priv/static_files`. All our static files will be in this directory.

    $> mkdir -p priv/static_files

Re-run `iex -S mix` and then let's try to add a static file inside the `static_files`
folder as a sanity check. Access it with your browser.

![lily](http://i.imgur.com/ijQEq98.png)

Easy, right?!

## Serving a Markdown File

This is where the fun begins. The idea is this: when a user enters `http://localhost:8000/some-markdown-file`, our application will look through a file named `some-markdown-file.md` inside the `priv/contents/` folder, read through it, convert it into HTML, and return it so the user will receive HTML contents in their browser as the response.

First things first, let's change our Cowboy route to accomodate that.

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

This route will accept anything the user inputs in their url.  We also need to change our handler function in `dds_blog/handler.ex`. In Cowboy terms, this is called a [binding](http://ninenines.eu/docs/en/cowboy/1.0/manual/cowboy_req/index.html#bindings). At first, I though it was a [query string](http://ninenines.eu/docs/en/cowboy/1.0/manual/cowboy_req/index.html#qs_vals), but I was wrong. [Query]() will accept the `http://localhost:8000/?query=yes` kind of format. But we want to achieve `http://localhost:8000/some-file`, so we use [bindings](http://ninenines.eu/docs/en/cowboy/1.0/manual/cowboy_req/index.html#bindings).

Let's open `lib/dds_blog/handler.ex` and handle a file requested by the user via urls. But first we open just one Markdown file for sanity check, as usual.

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

Then we create or add a Markdown file, rename it to `filename.md`, and put it in the `priv/contents` folder. If the folder doesn't exist yet, go ahead and make one. What we've done is use `:cowboy.bindings` to get a filename from urls. Then we passed the parameter into a helper function called `get_file`. The `get_file` function has two types: one with a parameter and one without parameters (a.k.a `:undefined` parameter).
If the user didn't include a filename in the url, our app will call `get_file` `:undefined` and return the message "Article doesn't exist". Otherwise, it will call `get_file` with `param`. 

After the app receives the parameter, it will read the file we already put inside the `priv/contents` directory.  At this point, we read the exact file named `filename.md`, then send it as a response to the user.

![Markdown raw](http://i.imgur.com/NHq0fHP.png)

It prints out Markdown text as raw. To make it return HTML, we need to convert Markdown to HTML first.  We can use the `markdown` package to handle that by including it in the `mix.exs` file.

    defp deps do
      [
        {:cowboy, "1.0.0"},
        {:markdown, github: "devinus/markdown"}
      ]
    end

Then get the dependencies with `mix`:

    $> mix deps.get

After that, we can access the `Markdown` module and use `to_html` to convert Markdown into HTML format. Let's do that now in the `lib/dds_blog/handler.ex` file inside the `get_file` function.


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

That's it! Quit and restart `iex -S mix`. Refresh your browser. It's HTML now.

![Imgur](http://i.imgur.com/hZwprG6.png)

Very cool! Ok, let's take a break. It's exhausting...

![meme](http://i.imgur.com/b6H4wKI.jpg)


Now, get back to work!! We need to read the `param` variable and load the Markdown file inside `priv/contents/` directory. To do that,
we concatenate strings and then read the file. After the file loads, we convert it into HTML and return it.


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

Let's copy one more Markdown file into the `priv/contents/` folder, and rerun the `iex -S mix` command. Then we can call the file from the browser.  We copy a file named `basicfp.md` and call it with `http://localhost:8000/basicfp`.  And, voila!

![basicfp](http://i.imgur.com/K5gT0Y7.png)

Really cool, right?!

Now we need an index page. The index page will show you a glimpse of all the content we have. We need to iterate through the `priv/contents` folder to get all Markdown files, then print it in the index file.


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

When the routes don't receive any parameters, we default to the index page. We show all the files inside `priv/contents` using the power of functional programming: recursion! Take a look at the two `print_articles` functions.  We start the recursion by calling the `print_articles` function with a list of files we got from the `File.ls` command, followed by an empty string. `print_articles` will loop through (read file and concatenate) all files until it reaches an empty list. Then it will call the second `print_articles` function that simply does the termination point of the recursion. We also truncate it so it's not too long, and add a "More" button linking to the full article.

Re-run `iex -S mix` and let's check if it worked. Point the browser to `http://localhost:8000/` and we will now see all the articles, truncated and with a `More` button followed with an `<hr />` tag. Very nice, right?!

![truncated](http://i.imgur.com/Y29KOT1.png)

If you click `More`, the link also works well, redirecting us to a view of the full article.

> If you noticed, the Markdown file didn't truncate properly. If you know how to truncate Markdown properly, please let me know.


## Templates And Themes

When you view the source of our page -- either the index page or detail page -- it will print out a Markdown-formatted file immediately; the page is not formatted as HTML. We need to take care of this by printing out the Markdown content inside some divs. This is what we will do now, adding some css framework to make our pages beautiful.

We will use [Skeleton, a responsive css boilerplate](http://getskeleton.com/). You're free to use any other css framework out there. Download the css files, and images (and/or javascript as well, if included in the framework) then copy it into our static file directory `priv/static_files`.

    priv/static_files/
    ├── css
    │   ├── normalize.css
    │   └── skeleton.css
    └── images
        └── favicon.png


We are also creating a new folder, `priv/themes`, to put our template files in. We'll add one file in there named `index.html.eex`. Notice that we add the `eex` extension to the HTML file because we want to bind some variables to the HTML using the `EEx` templating engine provided by Elixir.

    priv/themes/
    └── index.html.eex

Now we edit that `index.html.eex` file and replace the static file url to meet our Cowboy static url settings.


    <!DOCTYPE HTML>
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

As you can see, we also added `<%= content %>` to bind a content variable inside our `container>row` divs. Then we can compile the `eex` file and return HTML inside our `handler.ex` file. Let's do that right now. We also add `<%= title %>` to include HTML title changes if we move through pages.

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


That's it! Restart everything with the `iex -S mix` command and see what happens in your browser by refreshing it.

![Beauty](http://i.imgur.com/qlSIW6w.png)

If we click the "More" button, we also see one beautiful detail page. 

We're pretty much finished here, but before we wrap up, make the "More" button more appealing to click then we refactor it a little bit.

Let's do the "More" button first. Just add class `button button-primary` to the `a` tag.

    def print_articles [h|t], index_contents do
      {:ok, article} = File.read "priv/contents/" <> h
      sliced = String.slice article, 0, 1000
      marked = Markdown.to_html sliced
      filename = String.slice(h, 0, String.length(h) - 3)
      more = "<a class='button button-primary' href='#{filename}'>More</a><hr />"
      print_articles t, index_contents <> marked <> more
    end

We should refactor this thing a little bit. By moving out the HTML thingy to the themes folder, we can just eval `eex` into the `more` variable.

    def print_articles [h|t], index_contents do
      {:ok, article} = File.read "priv/contents/" <> h
      sliced = String.slice article, 0, 1000
      marked = Markdown.to_html sliced
      filename = String.slice(h, 0, String.length(h) - 3)
      more = EEx.eval_file "priv/themes/more_button.html.eex", [filename: filename]
      print_articles t, index_contents <> marked <> more
    end

And now we create a new template named `priv/themes/more_button.html.eex` with just one line of buttons and an `hr` tag. Then we will bind a filename into that.

    <a class='button button-primary' href='<%= filename %>'>More</a><hr />

Refresh the browser, just to see everything is ok. And we're done.

## Conclusion

We did a great job pulling it out together this simple flat file blogging engine. We built this engine using just two packages: `Cowboy` and `markdown`.

How cool is that?!

I know, I know, some portion of the code may be a little bit naive but we finished our mission and that's the important thing, right?! We can always improve anything else later.

This is the [full code](https://github.com/rizafahmi/dds-blog). You can always send us some issues and pull requests there for inputs, feedbacks, and contributions. That's it for me; see you next time!

## References

* [http://learnyousomeerlang.com/what-is-otp](https://github.com/ninenines/cowboy)
* [https://github.com/ninenines/cowboy](https://github.com/ninenines/cowboy)
* [http://elixir-lang.org/docs/stable/elixir/](http://elixir-lang.org/docs/stable/elixir/)
* [https://leanpub.com/web-development-using-elixir/](https://leanpub.com/web-development-using-elixir/)