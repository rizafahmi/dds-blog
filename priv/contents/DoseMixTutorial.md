# Let’s Mix Your Elixir

Even though Elixir is still young as a programming language, not 1.0 version yet (v0.12.5 at the moment this blog written), but it ships with great applications to create and deploying your projects. `IEx`, we already cover before. Today we will talk about `mix`.

According to [Elixir Website](http://elixir-lang.org/getting_started/mix/1.html) `mix` is a build tool that provides tasks for creating, compiling, testing and soon releasing Elixir projects. Mix is inspired by the [Leiningen](https://github.com/technomancy/leiningen) build tool for Clojure and was written by one of it contributors.

Today we will learn together how to create projects using `mix` and install dependencies for your projects.

## Create Project

To create a project, simply use `mix new` command followed by your project name:

	$> mix new dream_project

Mix automatically create a directory named dream_project with some files in it ready to start your engine and build your dream project.

		* creating README.md
		* creating .gitignore
		* creating mix.exs
		* creating lib
		* creating lib/dream_project.ex
		* creating lib/dream_project
		* creating lib/dream_project/supervisor.ex
		* creating test
		* creating test/test_helper.exs
		* creating test/dream_project_test.exs

	Your mix project was created successfully.
	You can use mix to compile it, test it, and more:

	cd dream_project
	mix compile
	mix test
	Run `mix help` for more information.

Even more, your project already OTP compatible, testable and ready to go. Let’s run test for this project.

	$> cd dream_project
	$> mix compile
	Compiled lib/dream_project/supervisor.ex
	Compiled lib/dream_project.ex
	Generated dream_project.app

	$> mix test
	Compiled lib/dream_project/supervisor.ex
	Compiled lib/dream_project.ex
	Generated dream_project.app
	.

	Finished in 0.2 seconds (0.1s on load, 0.03s on tests)
	1 tests, 0 failures


## Manage Dependencies

Another powerful feature that mix offer is managin dependencies across your project. If you noticed in our `dream_project` directory there is one file called `mix.exs`. That’s our project configuration including our collections of dependencies will listed in this file, in `reps` private function to be specific.

Now let’s add [ecto](https://github.com/elixir-lang/ecto) to our project.

	defp deps do
		[{ :ecto, github: “elixir-lang/ecto”}]
	end

Then we need to run `mix deps.get` and let’s see what happen.

    $> mix deps.get
    * Getting ecto (git://github.com/elixir-lang/ecto.git)
    Cloning into '/Users/riza/Developer/ElixirProjects/dream_project/deps/ecto'...
    remote: Reusing existing pack: 5565, done.
    remote: Total 5565 (delta 0), reused 0 (delta 0)
    Receiving objects: 100% (5565/5565), 1.42 MiB | 116.00 KiB/s, done.
    Resolving deltas: 100% (2413/2413), done.
    Checking connectivity... done
    * Getting poolboy (git://github.com/devinus/poolboy.git)
    Cloning into '/Users/riza/Developer/ElixirProjects/dream_project/deps/poolboy'...
    remote: Reusing existing pack: 654, done.
    remote: Total 654 (delta 0), reused 0 (delta 0)
    Receiving objects: 100% (654/654), 1.50 MiB | 110.00 KiB/s, done.
    Resolving deltas: 100% (305/305), done.
    Checking connectivity... done
    * Getting decimal (git://github.com/ericmj/decimal.git)
    Cloning into '/Users/riza/Developer/ElixirProjects/dream_project/deps/decimal'...
    remote: Reusing existing pack: 384, done.
    remote: Total 384 (delta 0), reused 0 (delta 0)
    Receiving objects: 100% (384/384), 120.93 KiB | 76.00 KiB/s, done.
    Resolving deltas: 100% (179/179), done.
    Checking connectivity... done

`mix` automatically clone ecto project from github we provided. Then `mix` also clone libraries that `ecto` depending on, in this case `poolboy`, and `decimal`. Cool, right?!

Now let’s add another library. I take this library from bitbucket.org.

	defp deps do
		[{ :ecto, github: “elixir-lang/ecto”},
		 { :excoder, bitbucket: “Nicd/excoder.git”}
		]
	end

Ok, now let's get the dependencies.

	$> mix deps.get
	* Getting excoder (Nicd/excoder)
	fatal: repository 'Nicd/excoder' does not exist
	** (Mix) Command `git clone --no-checkout --progress "Nicd/excoder" "/Users/riza/Developer/ElixirProjects/dream_project/deps/excoder"` failed

Up until now, seems like `mix` only support github. But don't worry, if your library of choice live outside github, we can add it with full url.

	defp deps do
		[{ :ecto, github: “elixir-lang/ecto”},
		 { :excoder, git: "https://bitbucket.org/Nicd/excoder.git"}
		]
	end

Let’s run `mix deps.get` once again.
	$> mix deps.get
		* Getting excoder (https://bitbucket.org/Nicd/excoder.git)
	Cloning into '/Users/riza/Developer/ElixirProjects/dream_project/deps/excoder'...
	remote: Counting objects: 36, done.
	remote: Compressing objects: 100% (29/29), done.
	remote: Total 36 (delta 9), reused 0 (delta 0)
	Checking connectivity... done

Cool! Now what if we want specific release version? `mix` can do that. For example, we want use plug version 0.2.0 instead of version 0.3.0. Easy, just mention it in `mix.exs`

	defp deps do
		[{ :ecto, github: “elixir-lang/ecto”},
		 { :excoder, git: "https://bitbucket.org/Nicd/excoder.git”},
		 { :plug, “== 0.2.0”, github: “elixir-lang/plug” }
		]
	end

You also can use `> 0.2.0` for anything later than 0.2.0 or in between `>= 0.2.0 and < 0.3.0`.

## Compiling Dependencies

What `mix deps.get` did before just clone the repo. Now it’s time for compiling it to use in our dream project.

	$> mix deps.compile
	Compiling poolboy
	==> poolboy (compile)
	….

Keep in mind, you always can use `mix help` to get more information and command for `mix`.


That’s it from me. Don’t forget to mention [@elixirdose](http://twitter.com/elixirdose) when your completed your dream project :)