# Phoenix Part 4
## Introduction

This week we continue our Phoenix series. In case you missed previous three part of this series, here you go:

1. [Let's Build Web App With Phoenix And Ecto](http://www.elixirdose.com/post/lets-build-web-app-with-phoenix-and-ecto)
2. [Phoenix, Ecto And Jobs Portal Project Part 2](http://www.elixirdose.com/post/phoenix-ecto-and-jobs-portal-project-part-2)
3. [Phoenix, Ecto And Jobs Portal Project Part 3](http://www.elixirdose.com/post/phoenix-ecto-and-jobs-portal-project-part-3)

Now we go further. We will add user registration and login. So if you want to post a new job, you need to login first. And if you don't have an account, you have to register first. You know the drill, I'm sure.

And this is the plan to tackle the issues:

1. Add Register User Form
2. Add Insert New User To Database
3. Add Login Form And Query
4. Using Session For Login Mekanism
5. Using Phoenix Flash To Messaging User

This will be one hell of the naive approach  for login mechanism. But it's ok for now, we will improve and iterate it through.

If you want follow along with me, this is the step you'll need:

1. git clone https://github.com/rizafahmi/phoenix-jobs-part-4.git
2. git checkout tags/finish-part-3
3. You're good to go!

## Add Register User
We will create register user first before we use the account for login. We will create route, one user controller and one view and template for register module.

### Add Register User Route

We need a rout for showing registration form.

    defmodule PhoenixJobsFour.Router do
      use Phoenix.Router

      scope alias: PhoenixJobsFour do
        get "/", PageController, :index, as: :pages
        resources "/jobs", JobController
        
        get "/users/new", UserController, :new, as: :user
      end

    end
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/9c0e1d4b14e16722245fa223ee22caa4b4b86154

### Add Register User Controller

Now after we create the route for new user form, next we create a new controller called `web/controllers/user_controller.ex`.

    defmodule PhoenixJobsFour.UserController do
      use Phoenix.Controller
      alias PhoenixJobsFour.Router

      def new(conn, _params) do
        render conn, "new"
      end
    end
    
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/5e916ee16d7c3605fac9054f56dd5f188c19892a
    
That's it for controller. Next we should add a view and template.

### Add Register User View And Template

We need to create a view for new user form and the form in html format as well. So here we go the new view in `web/views/user_view.ex`.


    defmodule PhoenixJobsFour.UserView do
      use PhoenixJobsFour.Views
    end
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/b6a5e2750caea9930f44715c06aaaf94839eac79

And this is the template in `web/templates/user/new.html.eex`. You have to create new folder named `user` and new file called `new.html.eex`.

    <h1>New User</h1>
    <form class="form-horizontal" action="/users" method="post">
      <div class="form-group">
        <label for="" class="col-sm-2 control-label">Email</label>
        <div class="col-sm-6"><input name="username" class="form-control" placeholder="yourname@email.com" type="email" required="required"></div>
      </div>
      <div class="form-group">
        <label for="" class="col-sm-2 control-label">Password</label>
        <div class="col-sm-6"><input name="password" class="form-control" type="password"></div>
      </div>
      <div class="form-group">
        <label for="" class="col-sm-2 control-label">Confirm Password</label>
        <div class="col-sm-6"><input class="form-control" type="password" name="confirmPassword"></div>
      </div>
      <div class="form-group">
        <div class="col-sm-offset-2 col-sm-10">
          <button class="btn btn-warning" type="submit">Save</button>
        </div>
      </div>
    </form>
    <!-- https://github.com/rizafahmi/phoenix-jobs-part-4/commit/030d1ed3b03c503f5a2c920be07f2e2f2bf88ad8 -->
    
Now run the Phoenix with `mix phoenix.start` and then go to `http://localhost:4000/users/new` in your browser. And you'll see the form.

![new](http://i.imgur.com/Jf1FMjE.png)


Trying to fill the form out, and click save. You'll see a message from Phoenix: `No route matches POST to ["users"]`. This is what we should do next.

## Add Insert New User

But before we handle `POST` data for new user, first we need to preparing the database and the table. We need to add a new model, migrating things to add a table and then we handle the `POST` thingy.

### Add Model User

Let's create one user model called `users` inside `web/models/users.ex`.

    defmodule PhoenixJobsFour.Users do
      use Ecto.Model

      schema "users" do
        field :username, :string
        field :password, :string
      end
    end


### Migration The Model

We have a model, now we can generate a migration script.

    $> mix ecto.gen.migration PhoenixJobsFour.Repo create_users
    * creating priv/repo/migrations
    * creating priv/repo/migrations/20140928145441_create_user.exs

Open up the file `ecto` generate (`priv/repo/migrations/20140928145441_create_user.exs`)  and type the code below.

    defmodule PhoenixJobsFour.Repo.Migrations.CreateUser do
      use Ecto.Migration

      def up do
        "CREATE TABLE users(
        id serial primary key,
        username varchar(75) unique,
        password varchar(125)
        )"
      end

      def down do
        "DROP TABLE users"
      end
    end
    
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/9b6f7bfcc8c6c5ff4e19851c5f53f2268e1672cf
    
Now we run the migration with this command:

    $> mix ecto.migrate PhoenixJobsFour.Repo
    * running UP _build/dev/lib/phoenix_jobs_four/priv/repo/migrations/20140928145441_create_user.exs

Our migration finished!

### Add Insert New User Route

We have to add one more route to handle `POST` data. Without further ado, let's create one. That's shouldbe easy, right?!

    defmodule PhoenixJobsFour.Router do
        use Phoenix.Router
            ....
            get "/users/new", UserController, :new, as: :user
            post "/users", UserController, :create, as: :user

    end
    
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/c52fb7e7257c71ecf1d78c4f355b523e8cb4c809

### Add Insert New User Controller

After we create route for creating new user, now we need to hadle the data and save it into database.

    defmodule PhoenixJobsFour.UserController do
      use Phoenix.Controller
      alias PhoenixJobsFour.Router

      def new(conn, _params) do
        render conn, "new"
      end

      def create(conn, params) do
        user = %PhoenixJobsFour.Users{username: params["username"], password: Crypto.md5(params["password"])}

        PhoenixJobsFour.Repo.insert(user)

        redirect conn, Router.pages_path(:index)

      end
    end
    
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/c20d7f632bdcc125443a0b53e5dcbb21742a5f65

What we did here is add a `%Users` struct with `params` data (username and password). And if you notice, we called `Crypto.md5` function to generate md5 for our password. But we didn't creat the function. This is what we need to do next.

### Add Helper For Generating md5 For Password

This useful module I found on `https://gist.github.com/10nin/5713366`.

    defmodule Crypto do
      def md5(str) do
        :crypto.hash(:md5, str)
          |> :erlang.bitstring_to_list
          |> Enum.map(&(:io_lib.format("~2.16.0b", [&1])))
          |> List.flatten
          |> :erlang.list_to_bitstring
      end
    end

It's simple to use. Just run like this:

    iex(1)> Crypto.md5("mysecurepassword")
    "50b9798b5454b52f93f37b15ad4680cd"

That's it! We can now use it to generate password and comparing passwords in login mekanism.

Now let's re-run the Phoenix and go to `http://localhost:4000/users/new` and then fill some data then save it. Open up your postgres database, you'll see the data saved.

    phoenix_jobs_four=# SELECT * FROM users;
     id |      username       |             password
    ----+---------------------+----------------------------------
      1 | rizafahmi@gmail.com | 99bfdc33d79bfedb2a6449a68faf5c8e
      2 | riza@harukaedu.com  | 99bfdc33d79bfedb2a6449a68faf5c8e
    (2 rows)

## Add Login System

Now we able to register a new user it's time to add login system. First thing to do is to add route then add template for our login form.

### Add Route Login

Simply add `get "/users/login", UserController, :login, as: :user` into `web/router.ex` then we can moving forward.

    defmodule PhoenixJobsFour.Router do
      use Phoenix.Router

      scope alias: PhoenixJobsFour do
        get "/", PageController, :index, as: :pages
        resources "/jobs", JobController
        get "/users/new", UserController, :new, as: :user
        get "/users/login", UserController, :login, as: :user
        post "/users", UserController, :create, as: :user
      end

    end
    
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/5071d060d8652bf00505112f96447688f071a851

### Add Login Template 

Add new file in `web/templates/user/login.html.eex` and add the html below.

    <h1>Login</h1>
    <form class="form-horizontal" action="/users" method="post">
      <div class="form-group">
        <label for="" class="col-sm-2 control-label">Email</label>
        <div class="col-sm-6"><input class="form-control" placeholder="yourname@email.com" name="username" type="email" required="required"></div>
      </div>
      <div class="form-group">
        <label for="" class="col-sm-2 control-label">Password</label>
        <div class="col-sm-6"><input name="password" class="form-control" type="password"></div>
      </div>
      <div class="form-group">
        <div class="col-sm-offset-2 col-sm-10">
          <button class="btn btn-warning" type="submit">Login</button>
        </div>
      </div>
    </form>
    
    <!-- https://github.com/rizafahmi/phoenix-jobs-part-4/commit/5071d060d8652bf00505112f96447688f071a851 -->
    
![Login](http://i.imgur.com/NT2RVSJ.png)

We also need to add login button and register button to the index template.

    <div class="row">
      <div class="col-md-4">
        <h2>List Of Jobs</h2>
      </div>
      <div class="col-md-8" style="text-align: right">
        <a href="<%= job_path(:new) %>" class="btn btn-danger">Post a new job</a>
        <a href="<%= user_path(:new) %>" class="btn btn-success">Register</a>
        <a href="<%= user_path(:login) %>" class="">Login</a>
      </div>
    </div>
    <ul class="list-unstyled" style="">
      <%= for job <- @jobs do %>
      <li class="job-list">
        <div class="row">
          <div class="col-md-9">
            <a href="/jobs/<%= job.id %>">
              <span class="title"><%= job.title %></span>
              <span class="label label-success"><%= job.job_type %></span>
              <span class="label label-default"><%= job.job_status %></span>
            </a>
          </div>
          <div class="col-md-3 buttons" style="text-align: right">
            <form method="post" action="<%= job_path(:destroy, job.id) %>" >
              <a href="/jobs/<%= job.id %>/edit" class="btn btn-warning btn-sm">
                Edit</a> &nbsp;&nbsp;
              <input type="hidden" name="_method" value="DELETE">
              <button type="submit" class="btn btn-default btn-sm">
                Delete</button>
            </form>
          </div>
        </div>
      </li>
      <% end %>
    </ul>
    
    <!-- https://github.com/rizafahmi/phoenix-jobs-part-4/commit/5071d060d8652bf00505112f96447688f071a851 -->

![Login button](http://i.imgur.com/tWpKk9M.png)

### Add Login Query

We add new query that we will use for login. Open up `web/models/queries.ex` and add new function called `login`. We also used `Crypto.md5` function to matching the password on database and the password on the form that user input.

    defmodule PhoenixJobsFour.Queries do
      import Ecto.Query
      alias PhoenixJobsFour.Jobs
      alias PhoenixJobsFour.Users
      alias PhoenixJobsFour.Repo

      def jobs_query do
        query = from job in Jobs,
                order_by: [desc: job.id],
                select: job
        Repo.all(query)
      end

      def job_detail_query(id) do
        int_id = String.to_integer(id)
        query = from job in Jobs,
                where: job.id == ^int_id,
                select: job
        Repo.all(query) |> List.first
      end

      def login(username, password) do
        md5_password = Crypto.md5(password)
        query = from user in Users,
                where: user.username == ^username,
                where: user.password == ^md5_password,
                select: user
        Repo.all(query) |> List.first
      end
    end
    
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/2f26ec4f883e43af6526842fc1ccc43d64c7d2f9

### Add Login Process

After creating the query, then we need to handle the login process: matching username and password from user input with the database using query that we create before. To do this open up `web/controllers/user_controller.ex` then add function called `login_process`.

    def login_process(conn, params) do
        user = PhoenixJobsFour.Queries.login(params["username"], params["password"])
        if user == nil do
          render conn, "login", [message: "Username and or password was wrong"]
        else
          put_session(conn, :username, params["username"])
          redirect conn, Router.pages_path(:index)
        end
    end
    
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/94a6e6669df993a99a27bd831f1c20186d41759e


If login success, we just put session with username in it. So we can check if the session is empty, that mean user is not login. Otherwise user is logged-in.

One more thing to add is router for login process. Open `web/routes.ex` and add one.

    post "/users/login", UserController, :login_process, as: :user

### Check User Login

Now we can do check login status for user. If user logged-in, we can show them logout button and they will able to post a new job. Otherwise, they will redirect to login page if they try to post a new job.

We change our index function inside `web/controllers/page_controller.ex`a little bit.

    defmodule PhoenixJobsFour.PageController do
      use Phoenix.Controller

      def index(conn, _params) do
        jobs = PhoenixJobsFour.Queries.jobs_query
        user = get_session(conn, :username)
        render conn, "index", [jobs: jobs, user: user]
      end

      def not_found(conn, _params) do
        render conn, "not_found"
      end

      def error(conn, _params) do
        render conn, "error"
      end
    end
    
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/74fa28e4a698775b992a4adf530f15698abca234

We make the user session available on template now we can add conditional on our template to incorporate that.

Open `web/templates/page/index.html.eex` and add conditional thing we talked about.

    <div class="col-md-8" style="text-align: right">
        <a href="<%= job_path(:new) %>" class="btn btn-danger">Post a new job</a>
        <%= if @user do %>
        <a href="<%= user_path(:new) %>" class="btn btn-success">Register</a>
        <a href="<%= user_path(:login) %>" class="">Login</a>
        <% else %>
        <a href="<%= user_path(:login) %>" class="">Logout</a>
        <% end %>
      </div>
    </div>
    
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/74fa28e4a698775b992a4adf530f15698abca234
    

This is the screenshot when the user not login yet. They can register or login. If they try to post a new job, they will also redirect to login page.

![Login](http://i.imgur.com/tWpKk9M.png)

And this is the screenshot when user logged-in. They can logout and able to post a new job.

![Logout](http://i.imgur.com/5RrfDuA.png)

But wait! We didn't add the logout process yet, right?! You're very right, but don't you worry, we've got you covered in the next section.

### Logout Process
It's simple. What we must do is just set the session to empty string. To do that we need to add additional route to `web/router.ex`

    get "/users/logout", UserController, :logout, as: :user
    
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/ea9a673982387d8127772a07a40ec4ecb1bf10e5
    
Then we add logout function in `web/
controllers/user_controller.ex`.

    def logout(conn, _params) do
        conn
        |> put_session(:username, "")
        |> redirect Router.pages_path(:index)
    end
    
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/ea9a673982387d8127772a07a40ec4ecb1bf10e5

Here you go!!

# Using Flash For Messaging

One thing to notice in our app, we didn't use any messaging at all. For example, if login failed, login success, etc. Phoenix has flash message feature that we can use for this purpose.

We do it by adding a message area in our global template. Open up `web/templates/layout/application.html.eex` then add a message area below the logo.

    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="">
        <meta name="author" content="">

        <title>Hello Phoenix!</title>
        <link rel="stylesheet" href="/css/app.css">
        <link rel="stylesheet" href="/css/jobs.css">
        <script src="/js/jquery-2.1.1.min.js"></script>
      </head>

      <body>
        <div class="container">
          <div class="header">
            <span class="logo"></span>
          </div>

          <%= if notice = Flash.get(@conn, :notice) do %>
          <div class="row">
            <div class="col md-12">
              <div class="alert alert-warning" role="alert"><%= notice %></div>
            </div>
          </div>
          <% end %>


          <%= @inner %>

          <div class="footer">
            <p>Made with ♥&nbsp;and <a href="http://phoenixframework.org">Phoenix Framework</a></p>
          </div>

        </div> <!-- /container -->
      </body>
    </html>
    
    <!-- https://github.com/rizafahmi/phoenix-jobs-part-4/commit/ea9a673982387d8127772a07a40ec4ecb1bf10e5 -->

Then we add alias to make it work. Open `web/views/layout_view.ex` and add the code below.

    defmodule PhoenixJobsFour.LayoutView do
      use PhoenixJobsFour.Views
      alias Phoenix.Controller.Flash

    end
    
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/ea9a673982387d8127772a07a40ec4ecb1bf10e5

We also need to revise the controller here and there. Open `web/controllers/user_controller.ex` and add `Flash.put` function each time we need to show message to user.

    defmodule PhoenixJobsFour.UserController do
      use Phoenix.Controller
      alias PhoenixJobsFour.Router
      alias Phoenix.Controller.Flash

      def new(conn, _params) do
        render conn, "new"
      end

      def create(conn, params) do
        user = %PhoenixJobsFour.Users{username: params["username"], password: Crypto.md5(params["password"])}
        PhoenixJobsFour.Repo.insert(user)

        redirect conn, Router.pages_path(:index)

      end

      def login(conn, _params) do
        render conn, "login"
      end

      def login_process(conn, params) do
        user = PhoenixJobsFour.Queries.login(params["username"], params["password"])
        if user == nil do
          conn
          |> Flash.put(:notice, "Username and or password was wrong")
          |> render "login"
        else
          conn
          |> Flash.put(:notice, "Login succees.")
          |> put_session(:username, params["username"])
          |> redirect Router.pages_path(:index)
        end
      end

      def logout(conn, _params) do
        conn
        |> put_session(:username, "")
        |> Flash.put(:notice, "Logout has been succeeded.")
        |> redirect Router.pages_path(:index)
      end
    end
    
    # https://github.com/rizafahmi/phoenix-jobs-part-4/commit/ea9a673982387d8127772a07a40ec4ecb1bf10e5
    
That's it! Our forth iteration of the product has finished. This is what the end product looks like.

![end](http://i.imgur.com/GgccoRx.png)

## Conclusion

Our forth iteration for this job portal is simply to implement registration, login and logout system. It's still very naive approach but we can still improve it in the future. Just give em time to grow, will you?!