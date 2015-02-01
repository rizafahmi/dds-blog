# Let's Build Web App With Phoenix and Ecto

Phoenix is the Elixir web framework targeting full-featured, fault tolerant applications with realtime functionality. Phoenix focuses on making developers highly productive without sacrificing performance. Phoenix is created by [Chris McCord](https://twitter.com/chris_mccord), available on [github](https://github.com/phoenixframework/phoenix), and has reached version 0.3.1.

If you want to know more about Phoenix, I suggest you watch McCord's talk at ElixirConf 2014 about the past, present, and future of Phoenix [here](http://www.confreaks.com/videos/4132-elixirconf2014-rise-of-the-phoenix-building-an-elixir-web-framework).

For this article, we will focus on how to create a web application using Phoenix, with Ecto as the persistence layer. We will build a simple job board that a user can browse for Elixir jobs and submit Elixir job opportunities.

Ok, let's get started by installing Phoenix. We will use the most recent version of Phoenix which is version 0.3.1, Ecto version 0.2.3, Elixir version 0.15.0, and Erlang version 17.

## Installing Phoenix

We need to install Phoenix first before we start to build the project. The installation process is easy. Just run these chains of command in your terminal. 

  $> git clone https://github.com/phoenixframework/phoenix.git && cd phoenix && mix do deps.get, compile

These commands will get the latest Phoenix from Github, get all dependencies needed for Phoenix, and then compile it.

If everything goes well, run this command to check whether Phoenix is installed or not:

  $> mix phoenix --help
    Help:

    mix phoenix.new     app_name destination_path  # Creates new Phoenix application
    mix phoenix.routes  [MyApp.Router]             # Prints routes
    mix phoenix.start   [MyApp.Router]             # Starts worker
    mix phoenix --help                             # This help

If you see the help message above, you're good to go!

**Heads up: ** *You need to be inside the phoenix directory to run this `mix phoenix --help` command.*

As you can see above, Phoenix added three new `mix` tasks for us to make our lives easier. Let's create a new Phoenix project using `mix phoenix.new`.


## Create Phoenix Project

What we need to do to create a new Phoenix project is just use `mix phoenix.new` inside our Phoenix directory that we cloned and compiled before. The command will be something like this.

  $> mix phoenix.new project_name /path/to/your/project

We will name our project `elixir_jobs`. The directory of the project should be outside of this Phoenix cloned directory.

  $> mix phoenix.new elixir_jobs ../elixir_jobs

    * creating ../phoenix_jobs
    * creating ../phoenix_jobs/.gitignore
    * creating ../phoenix_jobs/README.md
    * creating ../phoenix_jobs/config
    * creating ../phoenix_jobs/config/config.exs
    * creating ../phoenix_jobs/config/dev.exs
    * creating ../phoenix_jobs/config/locales
    * creating ../phoenix_jobs/config/locales/en.exs
    * creating ../phoenix_jobs/config/prod.exs
    * creating ../phoenix_jobs/config/test.exs
    ....

As you can see, there is a lot going on. But as soon this finishes, we're good to go. What `phoenix.new` did was bootstrap our Phoenix project. Now go to destination directory, get all dependencies, compile it. and try to start the Phoenix project.

  $> cd ../phoenix_jobs/
  $> mix do deps.get, compile
  $> mix phoenix.start
    Running Elixir.HelloPhoenix.Router with Cowboy on port 4000

Open the browser, type `http://localhost:4000/` in the url bar, and voila!

![phoenix](phoenix.png)


### Phoenix Directory Structure

Phoenix is Model-View-Controller, so we find the Phoenix directories structured in that way.

  ./
  ├── README.md
    ├── _build
    ├── config
    │   ├── config.exs
    │   ├── dev.exs
    │   ├── locales
    │   │   └── en.exs
    │   ├── prod.exs
    │   └── test.exs
    ├── deps
    ├── lib
    │   ├── hello_phoenix
    │   │   └── supervisor.ex
    │   └── hello_phoenix.ex
    ├── mix.exs
    ├── mix.lock
    ├── priv
    │   └── static
    │       ├── css
    │       │   └── app.css
    │       ├── images
    │       └── js
    │           └── phoenix.js
    ├── test
    │   ├── hello_phoenix_test.exs
    │   └── test_helper.exs
    └── web
    ├── channels
    ├── controllers
        │   └── page_controller.ex
        ├── i18n.ex
        ├── models
        ├── router.ex
        ├── templates
        │   ├── layout
        │   │   └── application.html.eex
        │   └── page
        │       └── index.html.eex
        ├── views
        │   ├── layout_view.ex
        │   └── page_view.ex
        └── views.ex

We need to focus on the `web` directory. Our controllers should be inside the `web/controllers` directory. Our views are in `web/views` and templates in `web/templates`. In Phoenix, views will render templates. A template is basically an `eex` file.

Now let's welcome Ecto to the party.


### Add Ecto To The Project

As you read from our [previous article](http://www.elixirdose.com/post/introduction-to-ecto), Ecto is a domain specific language for writing queries and interacting with databases in the Elixir language. Ecto is written in Elixir as a tool for relational databases.

We want to save jobs data to a database using Ecto. So we need to add Ecto to our project. To do that, we open the `mix.exs` file and add Ecto as a dependency inside the `deps` function. Ecto also needs the postgrex library to 'talk' to PostgreSQL database. So we also add postgrex as the dependency.

  defp deps do
        [
            {:phoenix, github: "phoenixframework/phoenix"},
            {:cowboy, "~> 1.0.0"},
            {:postgrex, "0.5.4"},
            {:ecto, "0.2.3"}
        ]
  end

We also need to update our applications list to include both `ecto` and `postgrex`.

  def application do
      [applications: [:phoenix, :cowboy, :postgrex, :ecto]]
    end

Then run `mix deps.get` in the terminal to get all the dependencies. If everything goes well, it'll be time to setup a repo.

### Create A Repo

A repo in ecto terms is the definition of a basic interface to a database, in this case PostgreSQL. Open up `web/models/repo.ex` and add this code below. If the directory doesn't exist, just create one.

  defmodule PhoenixJobs.Repo do
      use Ecto.Repo, adapter: Ecto.Adapters.Postgres
        
        def conf do
          parse_url "ecto://postgresuser:password@localhost/phoenix_jobs"
        end
        
        def priv do
          app_dir(:phoenix_jobs, "priv/repo")
        end
    end
    
Here we define the PostgreSQL connection with a URL format. All you have to change is `postgresuser`, `password`, and the `phoenix_jobs` database name. We will use migration features so the `priv` function is mandatory. We just need to tell where the migration script will be saved, which is in the `priv/repo` directory as the destination folder.

The next thing we should do is to make sure that our Repo module is started with our application, and that it is supervised. Let's open `lib/elixir_jobs.ex`.

  defmodule ElixirJobs do
      use Application
        
        def start(_type, _args) do
          import Supervisor.Spec
            tree = [worker(PhoenixJobsTwo.Repo, [])]
            opts = [name: PhoenixJobsTwo.Sup, strategy: :one_for_one]
            Supervisor.start_link(tree, opts)
        end
    end

To make sure everything is ok, let's compile the project:

  $> mix compile

If there is no error message, then we need to add a database, in this case called `elixir_jobs` using PostgreSQL's tools called `psql` in the terminal.

  $> psql -Upostgresuser -W template1
    Password for user postgresuser:
    
    template1=# CREATE DATABASE phoenix_jobs;
  CREATE DATABASE
  template1=# \q

Quit the `psql` using `\q` then add a model for us to query for.


### Create A Model

Let's make a separate file in `web/phoenix_jobs/jobs.ex`. Type the code below to make a model called **Jobs**.

  defmodule PhoenixJobs.Jobs do
      use Ecto.Model
        
        schema "jobs" do
          field :title, :string
            field :job_type, :string
            field :description, :string
            field :job_status, :string
        end
    end

If you run `mix help`, you'll see a couple of commands that we can use to migrate things, which is what we'll do now.


### Generate Migration Script

To generate a migration script, we use the `mix` command available when we first install Ecto. First, we want to able to create a job posting:

  $> mix ecto.gen.migration PhoenixJobs.Repo create_job
  * creating priv/repo/migrations
  * creating priv/repo/migrations/20140815040251_create_job.exs

Open the file that Ecto generates in `priv/repo/migrations/20140815040251_create_job.exs`. In this file we still have to write manual SQL for creating a table and dropping one. (The file name `20140815040251_create_job.exs` will vary depend on the date we generate the file.)

    defmodule PhoenixJobs.Repo.Migrations.CreateJob do
      use Ecto.Migration

      def up do
        ["CREATE TABLE jobs(id serial primary key, title varchar(125), job_type varchar(50), description text, job_status varchar(50))",
        "INSERT INTO jobs(title, job_type, description, job_status") VALUES ('Elixir Expert Needed', 'Remote', 'Elixir expert needed for writing article about Elixir every single week or two.', 'Part Time')"
        ]
      end

      def down do
        "DROP TABLE jobs"
      end
    end

What we did in this script is create a table and insert one dummy file when we run the migrate (`up` function). If we rollback to the previous migration, we will drop the table `jobs`.

After we done with a migration script, we can run the migration.


### Run The Migration

Running the migration is very easy. Let's do one:

  $> mix ecto.migrate PhoenixJobs.Repo
    * running UP _build/dev/lib/phoenix_jobs/priv/repo/migrations/20140815040251_create_job.exs

That's it! If you open the `phoenix_jobs` database on postgresql, you'll find a `jobs` table now. If we run `SELECT * FROM jobs`, the dummy data is there:

     Column    |          Type          |                   SELECT * FROM jobs;
  id |        title         | job_type |                                   description
                        | job_status
  ----+----------------------+----------+---------------------------------------------------------
  ------------------------+------------
    1 | Elixir Expert Needed | Remote   | Elixir expert needed for writing article about Elixir every single week or two. | Part Time
  (1 row)

One last thing we need from Ecto is to write a query for jobs.


### Create A Query

Create a new file called `queries.ex` inside the `web/models` directory. Start writing a query for getting all the jobs available.

    defmodule PhoenixJobsTwo.Queries do
      import Ecto.Query

      def jobs_query do
        query = from job in PhoenixJobsTwo.Jobs,
                select: job
        PhoenixJobsTwo.Repo.all(query)
      end
    end


We will call this query later from Phoenix's controller. 

We're done setting up Ecto. Now let's get back to the Phoenix part and create a jobs listing.

## Jobs Listing

If we open the file called `router.ex`, we will see the mapping from url/uri to controllers:

    defmodule HelloPhoenix.Router do
      use Phoenix.Router

      plug Plug.Static, at: "/static", from: :hello_phoenix
      get "/", PhoenixJobsTwo.PageController, :index, as: :page
    end

Routes basically map a URL/URI that users access from their web browser with controllers. For the example above, if a user accesses `http://127.0.0.1:4000/` with method `get`, it will be mapped to a controller called `PageController` and return all the data back to the user's web browser.

The Plug thing is for serving static files. Phoenix uses [Plug library](https://github.com/elixir-lang/plug).
More on routes later.

Now, let's open `web/controllers/page_controller.ex` and add a query that we created before.

    defmodule PhoenixJobsTwo.PageController do
      use Phoenix.Controller

      def index(conn, _params) do
        jobs = PhoenixJobsTwo.Queries.jobs_query
        render conn, "index", jobs: jobs
      end
    end

With this `jobs: jobs`, variable `jobs` will be available on the templates.

Let's restart our Phoenix server and refresh our browser to check that everything goes well, or not. If everything is ok, you'll see nothing different in the browser. Just make sure that there are no errors in the console.

Now let's move to the views and templates part. Views in Phoenix are responsible for rendering the templates. Templates use html and/or a format called Embedded Elixir (EEx). When a user hits one of the routes -- `/` for example -- it calls a particular controller it is associated with. Then in the controller we render a view, and that view will render templates and send it back to the user in html format.

We leave views as is; we're not going to use it for this moment. We may use view to create helper functions for our layouts. Sometimes you need special treatment or a calculation that can't be done in EEx or html.

Now we will iterate through a jobs query inside the template. Before that, let's take a look at a layout template in the `web/templates/layout/application.html.eex` file. That's the default layout that is created when we first started this Phoenix project. Let's make a small modification: change `<title>` for our page and leave anything else as is.

    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="">
        <meta name="author" content="">

        <title>Elixir Jobs</title>
        <link rel="stylesheet" href="/css/app.css">
      </head>

      <body>
        <div class="container">
          <div class="header">
            <ul class="nav nav-pills pull-right">
              <li><a href="https://github.com/phoenixframework/phoenix">Get Started</a></li>
            </ul>
            <span class="logo"></span>
          </div>

          <%= @inner %>

          <div class="footer">
            <p><a href="http://phoenixframework.org">phoenixframework.org</a></p>
          </div>

        </div> <!-- /container -->
      </body>
    </html>

One interesting thing in this template file is the `<%= @inner %>` part. That part basically will be replaced by a template file that is specified in a particular controller.

Open up `web/templates/page/index.html.eex`, remove all boilerplate code, and replace with this code below.

  <h1>List Of Jobs</h1>
    <ul>
    <%= for job <- @jobs do %>
      <li><%= job.title %> - <%= job.description %></li>
    <% end %>
    </ul>

We iterate through `jobs` variable that we make them available in templates from our controller. Refresh your browser, and you'll see one job available. That's it! Easy right?!

![joblist](joblist.png)

## Conclusion

Phoenix is a full-featured web framework. When combined with Ecto, it becomes more powerful. In this article, we used Phoenix to display a list of data that we get using Ecto. We also set up Ecto to play nicely with Phoenix, from creating a repo, migrating and inserting data, right up until we query to get some data back.

See you next time!

## References
* [Phoenix on Github](https://github.com/phoenixframework/phoenix)
* [Plug on Github](https://github.com/elixir-lang/plug)
* [Elixir Conf Phoenix Talk](http://confreaks.com/videos/4132-elixirconf2014-rise-of-the-phoenix-building-an-elixir-web-framework)
