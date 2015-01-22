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


## References

* http://learnyousomeerlang.com/what-is-otp
* https://github.com/ninenines/cowboy
