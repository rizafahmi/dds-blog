# Phoenix Ecto Part 2

Let's continue building our Elixir Job Portal this week. In the last article, we did following:

* Install Phoenix.
* Set up Phoenix.
* Install Ecto.
* Set up Ecto.
* Create a job listing.

This week we will add a job creation feature to our app. Let's get the ball rolling!


## Create Job

First, let's add a new route for creating a job by opening up `web/router.ex` and adding a new route for a new job.

    defmodule PhoenixJobs.Router do
      use Phoenix.Router

      get "/", PhoenixJobs.PageController, :index, as: :page
      get "/new", PhoenixJobs.PageController, :new
    end

Then open `web/controller/page_controller.ex` and add a new function to handle our `:new` route.

	defmodule PhoenixJobs.PageController do
      use Phoenix.Controller

      def index(conn, _params) do
        jobs = PhoenixJobs.Queries.jobs_query
        render conn, "index", jobs: jobs
      end

      def new(conn, _params) do
        render conn, "new"
      end
    end

After that, we need to create a template for this new job thingy. Let's create a template named "new" in `web/templates/page/new.html.eex` and add in the code below.

    <div class="row">
      <div class="col-lg-12">
        <h1>New Job</h1>
        <form class="form-horizontal" action="" name="newJob">

          <div class="form-group">
            <label for="title" class="col-sm-2 control-label">Job Title</label>
            <div class="col-sm-10">
              <input type="title" class="form-control" id="title" placeholder="Job Title" required="required">
            </div>
          </div>

          <div class="form-group">
            <label for="description" class="col-sm-2 control-label">Job Description</label>
            <div class="col-sm-10">
              <textarea id="description" placeholder="Job description..." class="form-control" name="description" cols="30" rows="10" required="required"></textarea>
    </div>
          </div>

          <div class="form-group">
            <label for="type" class="col-sm-2 control-label">Job Type</label>
            <div class="col-sm-10">
              <input type="type" class="form-control" id="type" placeholder="Job Type">
            </div>
          </div>
          <div class="form-group">
            <label for="status" class="col-sm-2 control-label">Job Status</label>
            <div class="col-sm-10">
              <input type="status" class="form-control" id="status" placeholder="Job Status">
            </div>
          </div>

          <div class="form-group">
            <div class="col-sm-offset-2 col-sm-10">
              <button type="submit" class="btn btn-warning">Save</button>
            </div>
          </div>

        </form>
      </div>

    </div>

If you're pointing your browser to `http://localhost:4000/new`, you'll see something like this.

![screenshot new](new-form.png)

If you fill out the form and click save, the form is working but still doing nothing other than submitting the form. We need to get the data from the form and save it to the database. To do that, first we need a new route to handle post data.

    defmodule PhoenixJobs.Router do
      use Phoenix.Router

      get "/", PhoenixJobs.PageController, :index, as: :index
      get "/new", PhoenixJobs.PageController, :new, as: :new
      post "/new", PhoenixJobs.PageController, :save, as: :save

    end

Then we handle saving data inside our `PageController` in `web/controllers/page_controller.ex`:

    defmodule PhoenixJobs.PageController do
      use Phoenix.Controller
      alias PhoenixJobs.Router

      def index(conn, _params) do
        jobs = PhoenixJobs.Queries.jobs_query
        render conn, "index", jobs: jobs
      end

      def new(conn, _params) do
        render conn, "new"
      end

      def save(conn, params) do
        job = %PhoenixJobs.Jobs{title: params["title"], description: params["description"], job_type: params["type"], job_status: params["status"]}
        PhoenixJobs.Repo.insert(job)
        redirect conn, Router.index_path(:index)
      end
    end

Very straightforward. First, we get the data from the form using the `params` variable and creating a `Jobs` struct. Then we insert to the database with the `Repo.insert` function. After that, we redirect to the index page.

Don't forget to add a button to redirect us from the index page to a new page in our templates.

    <h1>List Of Jobs</h1>
    <ul>
    <%= for job <- @jobs do %>
      <li><%= job.title %> - <%= job.description %></li>
    <% end %>
    </ul>

    <a href="/new" class="btn btn-success">Post a new job</a>

Restart the server, and let's try it! Open `http://localhost:4000` in your browser and click the "Post a new job" button to add a new job. Then fill out the form then click "Save".

![new-index](joblist-2.png)

Our new job button appears at the end of the list. Let's change the ordering in the query so the new job option is always on the top of the list.

    defmodule PhoenixJobs.Queries do
      import Ecto.Query

      def jobs_query do
        query = from job in PhoenixJobs.Jobs,
                order_by: [desc: job.id],
                select: job
        PhoenixJobs.Repo.all(query)
      end
    end


## Bonus: Redesign The Page(s)

Our index page, even if not ugly, is not really good functionally. Let's change the the format so it will look better and function better. **Warning: This step will be purely HTML, CSS, and Bootstrap. If you follow along, copy-pasting the HTML and CSS would be ok ;) **

To do this, open up `web/templates/page/index.html.eex` and change the current code to this code below.

	<div class="row">
	  <div class="col-md-4">
	    <h2>List Of Jobs</h2>
	  </div>
	  <div class="col-md-8">
	    <a href="/new" class="btn btn-danger pull-right">Post a new job</a>
	  </div>
	</div>
	<ul class="list-unstyled" style="">
	<%= for job <- @jobs do %>
	  <li class="job-list">
	    <a href="/job/<%= job.id %>">
	      <span class="title"><%= job.title %></span>
	      <span class="label label-success"><%= job.job_type %></span>
	      <span class="label label-default"><%= job.job_status %></span>
	    </a>
	  </li>
	<% end %>
	</ul>

One interesting point was `<a href="/job/<%= job.id %>">`. We will add a new route to map `http://localhost:4000/job/:id` to our detail page later.

Moving on,we also need to change our layout in `web/templates/layout/application.html.eex`:

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
	  </head>
	
	  <body>
	    <div class="container">
	      <div class="header">
	        <span class="logo"></span>
	      </div>
	
	      <%= @inner %>
	
	      <div class="footer">
	        <p>Made with ♥&nbsp;and <a href="http://phoenixframework.org">Phoenix Framework</a></p>
	      </div>
	
	    </div> <!-- /container -->
	  </body>
	</html>

We also need to add some style. Create a new css file named `priv/static/css/jobs.css`.

	.footer {
	  margin-top: 50px;
	}
	.job-list {
	  padding: 10px;
	  border-bottom: 1px solid #ccc;
	}
	li a {
	 color: #428bca;
	 text-decoration: none;
	}
	
	li a .title {
	 font-size: 1.2em;
	}


## Detail Page

Because we changed the layout and page structure, we need one more page to add: the job detail page. Let's create it now. First we need to add a new route:

	defmodule PhoenixJobs.Router do
	  use Phoenix.Router
	
	  get "/", PhoenixJobs.PageController, :index, as: :index
	  get "/new", PhoenixJobs.PageController, :new, as: :new
	  post "/new", PhoenixJobs.PageController, :save, as: :save
	  get "/job/:id", PhoenixJobs.PageController, :job, as: :job
	
	end

Then we need to add a new template for the detail page, as well, in `web/templates/page/job.html.ex`.

    <div class="row">
      <div class="col-md-12">
        <h2><%= @job.title %></h2>
        <h4>
          <span class="label label-success">
            <%= @job.job_type %>
          </span> &nbsp;
          <span class="label label-default">
            <%= @job.job_status %>
          </span>
        </h4>
      </div>
      <div class="col-md-12">
        <p>
        <%= @job.description %>
        </p>
      </div>
      <div class="col-md-12">
        <a href="/" class="btn btn-success">Back</a>
      </div>
    </div>



## Edit A Job
Let's add a new feature: edit a job post. 

Add a new route for edit, then add an edit button in the index page, query the data, and display it on the edit template. Finally, handle the editing process on the controller.

    defmodule PhoenixJobs.Router do
      use Phoenix.Router

      get "/", PhoenixJobs.PageController, :index, as: :index
      get "/new", PhoenixJobs.PageController, :new, as: :new
      post "/new", PhoenixJobs.PageController, :save, as: :save
      get "/job/:id", PhoenixJobs.PageController, :job, as: :job
      get "/job/:id/edit", PhoenixJobs.PageController, :edit, as: :edit

    end

We need to add the `:id` part so we will get the appropriate job id to edit for.

Now we add an edit button or link that will redirect the user to the edit page.

    <div class="row">
      <div class="col-md-4">
        <h2>List Of Jobs</h2>
      </div>
      <div class="col-md-8">
        <a href="/new" class="btn btn-danger pull-right">Post a new job</a>
      </div>
    </div>
    <ul class="list-unstyled" style="">
      <%= for job <- @jobs do %>
      <li class="job-list">
      <a href="/job/<%= job.id %>">
        <span class="title"><%= job.title %></span>
        <span class="label label-success"><%= job.job_type %></span>
        <span class="label label-default"><%= job.job_status %></span>
      </a>
      <a href="/job/<%= job.id %>/edit" class="btn btn-warning btn-sm pull-right">
        Edit</a>
      </li>
      <% end %>
    </ul>

Then we add a new template called `web/templates/page/edit.html.eex` obviously.

    <h2>Edit Job</h2>
    <form class="form-horizontal" action="/job/<%= @job.id %>" method="post">
      <div class="form-group">
        <label for="title" class="col-sm-2 control-label">Job Title</label>
        <div class="col-sm-10">
          <input type="text" class="form-control" value="<%= @job.title %>" name="title" placeholder="Job Title" required="required">
        </div>
      </div>

      <div class="form-group">
        <label for="description" class="col-sm-2 control-label">Job Description</label>
        <div class="col-sm-10">
          <textarea id="description" placeholder="Job description..." class="form-control" name="description" cols="30" rows="10" required="required"><%= @job.description %></textarea>
        </div>
      </div>

      <div class="form-group">
        <label for="type" class="col-sm-2 control-label">Job Type</label>
        <div class="col-sm-10">
          <input type="text" class="form-control" name="type" id="type" value="<%= @job.job_type %>" placeholder="Job Type">
        </div>
      </div>
      <div class="form-group">
        <label for="status" class="col-sm-2 control-label">Job Status</label>
        <div class="col-sm-10">
          <input type="text" class="form-control" name="status" placeholder="Job Status" value="<%= @job.job_status %>">
        </div>
      </div>

      <div class="form-group">
        <div class="col-sm-offset-2 col-sm-10">
          <button type="submit" class="btn btn-warning">Update</button>
        </div>
      </div>
    </form>

The last step for this feature is to add a controller to handle both showing current data to the form and updating the data when the user clicks the save/update button.

    defmodule PhoenixJobs.PageController do
      use Phoenix.Controller
      alias PhoenixJobs.Router

      def index(conn, _params) do
        jobs = PhoenixJobs.Queries.jobs_query
        render conn, "index", jobs: jobs
      end

      def new(conn, _params) do
        render conn, "new"
      end

      def save(conn, params) do
        job = %PhoenixJobs.Jobs{title: params["title"], description: params["description"], job_type: params["type"], job_status: params["status"]}
        PhoenixJobs.Repo.insert(job)
        redirect conn, Router.index_path(:index)
      end

      def job(conn, %{"id" => id}) do
        job = PhoenixJobs.Queries.job_detail_query(id)
        render conn, "job", job: job
      end

      def edit(conn, %{"id" => id}) do
        job = PhoenixJobs.Queries.job_detail_query(id)
        render conn, "edit", job: job
      end

      def update(conn, params) do
        IO.inspect params["type"]
        job = PhoenixJobs.Repo.get(PhoenixJobs.Jobs, params["id"])
        job = %{job | title: params["title"], description: params["description"],
          job_type: params["type"], job_status: params["status"]}
        PhoenixJobs.Repo.update(job)
        redirect conn, Router.index_path(:index)
      end
    end

## Delete Job

One more feature we need to complete our project is the ability to delete a job. Let's do that now. First, we add a delete button to the index page:

    <div class="row">
      <div class="col-md-4">
        <h2>List Of Jobs</h2>
      </div>
      <div class="col-md-8">
        <a href="/new" class="btn btn-danger pull-right">Post a new job</a>
      </div>
    </div>
    <ul class="list-unstyled" style="">
      <%= for job <- @jobs do %>
      <li class="job-list">
        <div class="row">
          <div class="col-md-9">
            <a href="/job/<%= job.id %>">
              <span class="title"><%= job.title %></span>
              <span class="label label-success"><%= job.job_type %></span>
              <span class="label label-default"><%= job.job_status %></span>
            </a>
          </div>
          <div class="col-md-3 buttons" style="text-align: right">
            <a href="/job/<%= job.id %>/edit" class="btn btn-warning btn-sm">
              Edit</a> &nbsp;&nbsp;
            <a href="/job/<%= job.id %>/delete" class="btn btn-default btn-sm">
              Delete</a>
          </div>
        </div>
      </li>
      <% end %>
    </ul>

As you can see, we point the delete into `/job/:id/delete`. Now let's create that route:

    defmodule PhoenixJobs.Router do
      use Phoenix.Router

      get "/", PhoenixJobs.PageController, :index, as: :index
      get "/new", PhoenixJobs.PageController, :new, as: :new
      post "/new", PhoenixJobs.PageController, :save, as: :save
      get "/job/:id", PhoenixJobs.PageController, :job, as: :job
      get "/job/:id/edit", PhoenixJobs.PageController, :edit, as: :edit
      post "/job/:id", PhoenixJobs.PageController, :update, as: :update
      get "/job/:id/:action", PhoenixJobs.PageController, :job, as: :delete
      post "/", PhoenixJobs.PageController,:destroy, as: :destroy

    end

We will use the detail page as the delete confirmation page with an additional delete button at the bottom of the page. We will check if `:action` is equal to delete, then we will show the delete button and a form for deletion. Otherwise, we only show a detail page without a delete button. So we edit `web/templates/page/job.html.eex` and add the button:

    <div class="row">
      <div class="col-md-12">
        <%= if @action == "delete" do %>
        <h2>Are you sure want to delete <%= @job.title %>??</h2>
        <%= else %>
        <h2><%= @job.title %></h2>
        <%= end %>
        <h4>
          <span class="label label-success">
            <%= @job.job_type %>
          </span> &nbsp;
          <span class="label label-default">
            <%= @job.job_status %>
          </span>
        </h4>
      </div>
      <div class="col-md-12">
        <p>
        <%= @job.description %>
        </p>
      </div>
      <div class="col-md-12">
        <form action="<%= destroy_path(:destroy) %>" method="post">
        <a href="/" class="btn btn-success">Back</a>
        <%= if @action == "delete" do %>
          <input type="hidden" name="id" value="<%= @job.id %>">
          <button type="submit" class="btn btn-danger pull-right">Delete</button>
        <%= end %>
        </form>
      </div>

    </div>

The last step we need to take care of the deletion process is on the controller. Let's do this now by opening `web/controllers/page_controller.ex` and adding a `destroy` function.

    defmodule PhoenixJobs.PageController do
      use Phoenix.Controller
      alias PhoenixJobs.Router

      ...

      def update(conn, params) do
        IO.inspect params["type"]
        job = PhoenixJobs.Repo.get(PhoenixJobs.Jobs, params["id"])
        job = %{job | title: params["title"], description: params["description"],
          job_type: params["type"], job_status: params["status"]}
        PhoenixJobs.Repo.update(job)
        redirect conn, Router.index_path(:index)
      end

      def destroy(conn, params) do
        job = PhoenixJobs.Queries.job_detail_query(params["id"])
        PhoenixJobs.Repo.delete(job)

        redirect conn, Router.index_path(:index)
      end
    end

That's it! We've got ourselves a job portal for fellow Elixir developers.

## Conclusion



## References
* [http://gogogarrett.sexy/programming-in-elixir-with-the-phoenix-framework-building-a-basic-CRUD-app/](http://gogogarrett.sexy/programming-in-elixir-with-the-phoenix-framework-building-a-basic-CRUD-app/)