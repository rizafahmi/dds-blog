# Phoenix Part 3

It's feels great when we use one framework and its owner gives us suggestions directly. That's what I got from the last article about Phoenix. [Chris McCord](https://twitter.com/chris_mccord) gave us three valuable suggestions to improve our Phoenix Job Portal. In this article, we will refactor the code a bit based on his valuable suggestion:

1. Change the "index" route helper to `as: :pages`, so you can do `pages_path(:index)` instead of `index_path(:index)`.
2. The Router should be updated to use the `resources` macro for conventional REST endpoints and conventionally named route helpers.
3. Alias `PhoenixJobs.Queriers` and `PhoenixJobs.Jobs` to keep the controller actions tidy.


## Change Index Route Helper

This change is a minor one and easy to implement. It's just a naming convention. We want to do `pages_path(:index)` instead of `index_path(:index)`.  To do that, we need to change `as: :index` to `as: pages` inside our route file:

	get "/", PhoenixJobsThree.PageController, :index, as: :pages

The impact of this change means we need to change all `index_path` parts in the controllers and views. Let's search for it and change it.

	web/controllers/page_controller.ex
	17:    redirect conn, Router.index_path(:index)
	36:    redirect conn, Router.index_path(:index)
	43:    redirect conn, Router.index_path(:index)

It looks like we have three redirections to `index_path` that we need to change by opening up our page controller (`web/controllers/page_controller.ex`).

	
    defmodule PhoenixJobsThree.PageController do
      use Phoenix.Controller
      alias PhoenixJobsThree.Router

      def index(conn, _params) do
        jobs = PhoenixJobsThree.Queries.jobs_query
        render conn, "index", jobs: jobs
      end

      def new(conn, _params) do
        render conn, "new"
      end

      def save(conn, params) do
        job = %PhoenixJobsThree.Jobs{title: params["title"], description: params["description"], job_type: params["type"], job_status: para
    ms["status"]}
        PhoenixJobsThree.Repo.insert(job)
        redirect conn, Router.pages_path(:index)
      end

      def job(conn, params) do
        job = PhoenixJobsThree.Queries.job_detail_query(params["id"])
        render conn, "job", [job: job, action: params["action"]]
      end

      def edit(conn, %{"id" => id}) do
        job = PhoenixJobsThree.Queries.job_detail_query(id)
        render conn, "edit", job: job
      end

      def update(conn, params) do
        IO.inspect params["type"]
        job = PhoenixJobsThree.Repo.get(PhoenixJobsThree.Jobs, params["id"])
        job = %{job | title: params["title"], description: params["description"],
          job_type: params["type"], job_status: params["status"]}
        PhoenixJobsThree.Repo.update(job)
        redirect conn, Router.pages_path(:index)
      end

      def destroy(conn, params) do
        job = PhoenixJobsThree.Queries.job_detail_query(params["id"])
        PhoenixJobsThree.Repo.delete(job)

        redirect conn, Router.pages_path(:index)
      end
    end

Let's test the app manually by adding a new job, then edit and delete it to see if something is wrong with the redirection we changed earlier.

![index2](index_2.png)
![new2](new_2.png)

Ok, everything seems ok. That wraps up our first task.


## Update The Router

According to Chris' second suggestion, we're better off using the `resources` macro. So let's update our router.

	scope alias: PhoenixJobs do
		get "/", PageController, :index, as: :index
		resources "jobs", JobController
	end

We also we separated between `PageController` and `JobController`. It's good practice and will be helpful to separate the controllers based on their purposes, especially when the project is growing. We'll do controller separation later. Now let's focus on router changes first.

When we compile it, we will get error message.

	$> mix compile
	Compiled web/controllers/page_controller.ex
	Compiled web/views/layout_view.ex
	Compiled web/router.ex

	== Compilation error on file web/views/page_view.ex ==
	** (CompileError) web/templates/page/job.html.eex:23: function destroy_path/1 undefined
    (stdlib) lists.erl:1336: :lists.foreach/2
    (stdlib) erl_eval.erl:657: :erl_eval.do_apply/6
    (elixir) src/elixir.erl:175: :elixir.erl_eval/3
    (elixir) src/elixir.erl:163: :elixir.eval_forms/4
    (elixir) src/elixir_lexical.erl:17: :elixir_lexical.run/3
    (elixir) src/elixir.erl:175: :elixir.erl_eval/3

Phoenix complains that we didn't have `destroy_path`. Now we have a `jobs_path` with a `DELETE` method instead. But first, we should create our new `JobController` before we change the path problems. Create a new file `web/controllers/job_controller.ex`. We can copy a portion of the code from the page controller to get started.

    defmodule PhoenixJobsThree.JobController do
      use Phoenix.Controller
      alias PhoenixJobsThree.Router

      def index(conn, _params) do
        jobs = PhoenixJobsThree.Queries.jobs_query
        render conn, "index", jobs: jobs
      end

      def new(conn, _params) do
        render conn, "new"
      end

      def save(conn, params) do
        job = %PhoenixJobsThree.Jobs{title: params["title"], description: params["description"], job_type: params["type"], job_status: para
    ms["status"]}
        PhoenixJobsThree.Repo.insert(job)
        redirect conn, Router.pages_path(:index)
      end

      def job(conn, params) do
        job = PhoenixJobsThree.Queries.job_detail_query(params["id"])
        render conn, "job", [job: job, action: params["action"]]
      end

      def edit(conn, %{"id" => id}) do
        job = PhoenixJobsThree.Queries.job_detail_query(id)
        render conn, "edit", job: job
      end

      def update(conn, params) do
        IO.inspect params["type"]
        job = PhoenixJobsThree.Repo.get(PhoenixJobsThree.Jobs, params["id"])
        job = %{job | title: params["title"], description: params["description"],
          job_type: params["type"], job_status: params["status"]}
        PhoenixJobsThree.Repo.update(job)
        redirect conn, Router.pages_path(:index)
      end

      def destroy(conn, params) do
        job = PhoenixJobsThree.Queries.job_detail_query(params["id"])
        PhoenixJobsThree.Repo.delete(job)

        redirect conn, Router.pages_path(:index)
      end
    end

If we run the app, now Phoenix complains that `JobController` doesn't have a view. We should create one. Let's do it by adding a new file, `web/views/job_view.ex`.

    defmodule PhoenixJobsThree.JobView do
      use PhoenixJobsThree.Views

    end

This will get us another complaint: there was no template directory. Yes, Phoenix complains a lot! You'll get used to it, don't worry :)

Let's create the directory, shall we?! Make a directory in `web/templates/job`. When you re-run `mix phoenix.start`, Phoenix finally stops complaining. But not just yet. We don't have any templates inside the job directory just yet. So, let's copy all files from the page template directory into the job directory. We're moving this part around here, because we want to separate between page and job functionality. We will take care of the page part later (deleting code and files).

	$> cp -R ./web/templates/page/* ./web/templates/job/

When we start Phoenix, we'll be able to navigate to `http://localhost:4000/` and `http://localhost:4000/jobs` without any complaints. To keep it lean, let's remove unnecassary files inside page templates directory.

	$> rm web/templates/page/edit.html.eex web/templates/page/job.html.eex web/templates/page/new.html.eex

Let's see if there is another complaint by re-running Phoenix. It looks great; no complaints so far. Now we can remove some of the code inside `PageController` so it has one function only: index. Because `PageController` just needs the index page, the other function will handle s`JobController`.

    defmodule PhoenixJobsThree.PageController do
      use Phoenix.Controller
      alias PhoenixJobsThree.Router

      def index(conn, _params) do
        jobs = PhoenixJobsThree.Queries.jobs_query
        render conn, "index", jobs: jobs
      end

    end


Re-run Phoenix and it should be ok. But when we try to add new job, or edit, or delete, we get another complain. It's because we didn't adapt to a new routes just yet. Let's do that now.


### New Job Roudte

We should open `web/templates/page/index.html.eex`. First, we need to change the `/new` link to `/jobs/new`.

    <div class="row">
      <div class="col-md-4">
        <h2>List Of Jobs</h2>
      </div>
      <div class="col-md-8">
        <a href="<%= jobs_path(:new) %>" class="btn btn-danger pull-right">Post a new job</a>
      </div>
    </div>
	....

Then we open `web/templates/job/new.html.eex` and revise the form action destination.

    <h1>New Job</h1>
    <form class="form-horizontal" action="/jobs" method="post">
      <div class="form-group">
        <label for="title" class="col-sm-2 control-label">Job Title</label>
        <div class="col-sm-10">
          <input type="text" class="form-control" name="title" placeholder="Job Title" required="required">
        </div>
      </div>
	...

If we submit a new job right now, Phoenix will say that there is no route matching POST to `/jobs`. Why just `/jobs`? Because in our new routes, the save process will be handled by the `/jobs` route with method POST. In order to fix this, we must change our `JobController` save function which is the function we used before to save a new job that POST-ed to the form. We don't have the save function anymore; we now have the create the function instead. Long story short, just rename the save function into create. And we are done with new route changes.

    defmodule PhoenixJobsThree.JobController do
      use Phoenix.Controller
      alias PhoenixJobsThree.Router

      def index(conn, _params) do
        jobs = PhoenixJobsThree.Queries.jobs_query
        render conn, "index", jobs: jobs
      end

      def new(conn, _params) do
        render conn, "new"
      end

      def create(conn, params) do
        job = %PhoenixJobsThree.Jobs{title: params["title"], description: params["description"], job_type: params["type"], job_status: para
    ms["status"]}
        PhoenixJobsThree.Repo.insert(job)
        redirect conn, Router.pages_path(:index)
      end


	...


Moving on to the edit route now...

### Edit Job Route

Once again, open `web/templates/page/index.html.eex` and `web/templates/job/index.html.eex , search for the edit button part and link to detail page. We just need to change:

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
            <a href="/jobs/<%= job.id %>/edit" class="btn btn-warning btn-sm">
              Edit</a> &nbsp;&nbsp;
            <a href="/job/<%= job.id %>/delete" class="btn btn-default btn-sm">
              Delete</a>
          </div>
        </div>
    </li>

into something like this:

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
            <a href="/jobs/<%= job.id %>/edit" class="btn btn-warning btn-sm">
              Edit</a> &nbsp;&nbsp;
            <a href="/job/<%= job.id %>/delete" class="btn btn-default btn-sm">
              Delete</a>
          </div>
        </div>
    </li>

With this change, we will be able to see the edit form page and detail page.

Then open `web/templates/job/edit.html.eex` and edit the form action part from: 

	<form class="form-horizontal" action="/job/<%= @job.id %>" method="post">

into:


    <form class="form-horizontal" action="/jobs/<%= @job.id %>" method="post">

At this moment, if we run the Phoenix and try to edit a job and save it, Phoenix will complaint that no route matches POST to `jobs`.

This is because our resources routes used PATCH as the method instead of POST to update a job. If we change the form method into PATCH, html won't recognize it since html just has two options: GET and POST. Well, this is where html cannot catch up with modern web frameworks like Phoenix. Lucky for us, Phoenix is already thinking ahead and our problem is taken care of. It will override the POST method. What we need is add hidden input with name `_method`.


    <h2>Edit Job</h2>
    <form class="form-horizontal" action="<%= jobs_path(:update, @job.id) %>" method="post">
      <div class="form-group">
        <label for="title" class="col-sm-2 control-label">Job Title</label>
        <div class="col-sm-10">
		  <input type="hidden" name="_method" value="PATCH">
          <input type="text" class="form-control" value="<%= @job.title %>" name="title" placeholder="Job Title" required="required">
        </div>
      </div>

      <div class="form-group">
        <label for="description" class="col-sm-2 control-label">Job Description</label>
        <div class="col-sm-10">
          <textarea id="description" placeholder="Job description..." class="form-control" name="description" cols="30" rows="10" required=
    "required"><%= @job.description %></textarea>
        </div>
      </div>
	...








Those are pretty much it. We now able to save changed. Try by yourself if you don't believe me :)

### Show Job Route

Now if you click on the job title link, Phoenix will complain that there is no `JobController.show` function. We used `def job` before, so the change is easy. We just have to rename the function from `job` to `show` inside our `web/controllers/job_controller.ex`.

    ...
    
    def show(conn, params) do
        job = PhoenixJobsThree.Queries.job_detail_query(params["id"])
        render conn, "job", [job: job, action: params["action"]]
    end
    
    ...

### Delete Job Route

One last route that we need to update is deletion route. First, we have to update our `web/templates/page/index.html.eex` file. Find the delete button part. Right now the delete button just a link to delete view.

    <a href="/job/<%= job.id %>/delete" class="btn btn-default btn-sm">Delete</a>

We have to change it into a form that will call `destroy` route and using `DELETE` method using method override like we did before.

    <div class="col-md-3 buttons" style="text-align: right">
       <form method="post" action="<%= jobs_path(:destroy, job.id) %>" >
         <a href="/jobs/<%= job.id %>/edit" class="btn btn-warning btn-sm">
           Edit</a> &nbsp;&nbsp;
         <input type="hidden" name="_method" value="DELETE">
         <button type="submit" class="btn btn-default btn-sm">
           Delete</button>
       </form>
    </div>

That's it! Now if we click delete button, it will actually delete a job for us.

## Alias Queries

One last suggestion is to use alias to keep our code tidy. In the last article, we use something like this: `PhoenixJobs.Jobs` and `PhoenixJobs.Repo.all`. We want to remove repeating `PhoenixJobs.` by using alias.

Open up `web/models/queries.ex` and change the whole file with the code below:

    defmodule PhoenixJobsThree.Queries do
      import Ecto.Query
      alias PhoenixJobsThree.Jobs
      alias PhoenixJobsThree.Repo

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
    end

Also, we should use an alias inside our `web/controllers/job_controller.ex`.

    defmodule PhoenixJobsThree.JobController do
      use Phoenix.Controller
      alias PhoenixJobsThree.Router
      alias PhoenixJobsThree.Jobs
      alias PhoenixJobsThree.Repo
      alias PhoenixJobsThree.Queries

      def index(conn, _params) do
        jobs = Queries.jobs_query
        render conn, "index", jobs: jobs
      end

      def new(conn, _params) do
        render conn, "new"
      end

      def create(conn, params) do
        job = %Jobs{title: params["title"], description: params["description"], job_type: params["type"], job_status: params
    ["status"]}
        Repo.insert(job)
        redirect conn, Router.pages_path(:index)
      end
        def show(conn, params) do
        job = Queries.job_detail_query(params["id"])
        render conn, "job", [job: job, action: params["action"]]
      end

      def edit(conn, %{"id" => id}) do
        job = Queries.job_detail_query(id)
        render conn, "edit", job: job
      end

      def update(conn, params) do
        IO.inspect params["type"]
        job = Repo.get(PhoenixJobsThree.Jobs, params["id"])
        job = %{job | title: params["title"], description: params["description"],
          job_type: params["type"], job_status: params["status"]}
        Repo.update(job)
        redirect conn, Router.pages_path(:index)
      end
queryedx                                                                                                                                                                                                                    
      def destroy(conn, params) do
        job = Queries.job_detail_query(params["id"])
        Repo.delete(job)

        redirect conn, Router.pages_path(:index)
      end
    end

And don't forget our `PageController`.

    defmodule PhoenixJobsThree.PageController do
      use Phoenix.Controller
      alias PhoenixJobsThree.Router
      alias PhoenixJobsThree.Queries

      def index(conn, _params) do
        jobs = Queries.jobs_query
        render conn, "index", jobs: jobs
      end

    end

Looks tidy, doesn't it?!

## Conclusion

We did a great job refactoring our project. Now our project usse REST-ist routes, and cleaner code by using aliases. Thanks to [Chris McCord](https://twitter.com/chris_mccord) for valuable feedback!