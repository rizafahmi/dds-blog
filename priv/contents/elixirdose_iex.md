# Back to Basics: IEx

IEx is the Interactive Elixir environment.  It's a simple yet powerful tool that is useful for debugging and testing code, learning the language, and a whole lot more.  It comes with Elixir, so it's available at your command line today.  If you plan on learning Elixir through any of the Elixir books or through websites like [ElixirDose.com](http://elixirdose.com), you'll see lots of IEx.

It's not a terribly complicated tool.  This tutorial will give you more than you need to know to get started in less than 10 minutes. 

## To Begin

Starting up IEx is as simple as going to your command line and typing its name in:

		[AugieDB] ~/elixir/dose/deck_part2 $ iex

		Erlang R16B02 (erts-5.10.3) [source-b44b726] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

		Interactive Elixir (0.12.3-dev) - press Ctrl+C to exit (type h() ENTER for help)
		iex(1)>


When IEx first starts up, it gives you the versions of Erlang and Elixir that are running.  The prompts are consecutively numbered for future reference.

If you're working on a project with the Mix framework, you can start up IEx with your project loaded into memory by going to the root directory of the project and typing `iex -S mix`, like this:

	[AugieDB] ~/elixir/dose/deck_part2 $ iex -S mix
	Erlang R16B02 (erts-5.10.3) [source-b44b726] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

	Interactive Elixir (0.12.3-dev) - press Ctrl+C to exit (type h() ENTER for help)
	iex(1)>

It doesn't come right out and say it, but the modules are there.  Trust me.  If they failed to load for some reason, you'd get an error message.

The capital "S" is important there.  Make it lowercase and IEx will load without your project.  

You also need to be in the root directory for your mix project.  If you're inside a subdirectory like 'lib' or 'test', it'll fail:

	[AugieDB] ~/elixir/dose/deck_part2 $ cd lib
	[AugieDB] ~/elixir/dose/deck_part2/lib $ iex -S mix
	Erlang R16B02 (erts-5.10.3) [source-b44b726] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

	** (Mix) Could not find a Mix.Project, please ensure a mix.exs file is available
	[AugieDB] ~/elixir/dose/deck_part2/lib $

When it's loading IEx, it's actually running the `mix.exs` file in the root directory.  So be sure you're all in the same place.

If you want to run an Elixir one-liner, you can execute that line when IEx starts with the `-e` option, the same as in Perl or Ruby's IRB:

	[AugieDB] ~/elixir/dose/deck_part2 $ iex -e "Enum.each([1,2,3], fn(x) -> IO.puts x end)"
	Erlang R16B02 (erts-5.10.3) [source-b44b726] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]

	1
	2
	3
	Interactive Elixir (0.12.3-dev) - press Ctrl+C to exit (type h() ENTER for help)
	iex(1)>

The results appear between the Erlang and Elixir openings.  If you're running a more complicated script that includes modules, those will be loaded into memory, as well.


## Inside IEx

Once you're inside IEx, you can load up a new module file by compiling it with the `c` command.

	iex(2)> c("lib/game.ex")
	lib/game.ex:1: redefining module Game
	[Game]

The parenthesis, by the way, are optional.  This will work, too:

	iex(3)> c "lib/game.ex"
	lib/game.ex:1: redefining module Game
	[Game]


If you make a change to an existing module in another window -- in a text editor, for example -- you can use the `r` command to reload the module to bring everything up to date. Not that you don't specify the file here. You just need the module name:

	iex(4)> r Game
	lib/game.ex:1: redefining module Game
	{:reloaded, Game, [Game]}

This is case sensitive.  You are creating your module names with a capital letter, right?


## Help

Of course, help is available for IEx.

Before you enter the environment, you can ask for help at the command like with the `--help` or `-h` flag:

		[AugieDB] ~/elixir/dose/shuffle_step $ iex --help
		Usage: iex [options] [.exs file] [data]

		  -v                Prints version
		  -e "command"      Evaluates the given command (*)
		  -r "file"         Requires the given files/patterns (*)
		  -S "script"       Finds and executes the given script
		  -pr "file"        Requires the given files/patterns in parallel (*)
		  -pa "path"        Prepends the given path to Erlang code path (*)
		  -pz "path"        Appends the given path to Erlang code path (*)
		  --app "app"       Start the given app and its dependencies (*)
		  --erl "switches"  Switches to be passed down to erlang (*)
		  --name "name"     Makes and assigns a name to the distributed node
		  --sname "name"    Makes and assigns a short name to the distributed node
		  --cookie "cookie" Sets a cookie for this distributed node
		  --hidden          Makes a hidden node
		  --detached        Starts the Erlang VM detached from console
		  --remsh "name"    Connects to a node using a remote shell
		  --dot-iex "path"  Overrides default .iex file and uses path instead;
		                    path can be empty, then no file will be loaded

		** Options marked with (*) can be given more than once
		** Options given after the .exs file or -- are passed down to the executed code
		** Options can be passed to the erlang runtime using ELIXIR_ERL_OPTS or --erl

When you're inside the environment, the 'h' command (with our without parentheses afterwards), will give you a quick guide to the available commands:

		iex(4)> h()

		                                  IEx.Helpers

		Welcome to Interactive Elixir. You are currently seeing the documentation for
		the module IEx.Helpers which provides many helpers to make Elixir's shell more
		joyful to work with.

		This message was triggered by invoking the helper h(), usually referred to as
		h/0 (since it expects 0 arguments).

		There are many other helpers available:

		[..]


You can look up documentation from inside IEx, as well.  As long as the method has documention included with it -- and all of core Elixir does -- you can specify that module or function and learn more about it.

	iex(5)> h(Stream)

	                                     Stream

	Module for creating and composing streams.

	Streams are composable, lazy enumerables. Any enumerable that generates items
	one by one during enumeration is called a stream. For example, Elixir's Range
	is a stream:

	[...]

It doesn't work with Erlang features, though:

	iex(6)> h(:httpc)
	:httpc is an Erlang module and, as such, it does not have Elixir-style docs

You'll need to consult [the Erlang docs](http://www.erlang.org/erldoc) for that.

## Auto-Complete

IEx also has auto-complete. My card game starts in the `Game` module with a function whose name I always forget. It starts with "play."  I can remember that much.  So if I type that:

	iex(7)> Game.play

...and then hit the tab button, it offers me suggestions the same way the command line does when I need auto-complete to remember a file name:

	iex(7)> Game.play_
	play_a_game/0    play_card/2

Finish the command and away you go.


### History

Like many Linux shells have at the command line, IEx has a history command, also.  In this case, `v` is the key to returning your most recent commands:

	iex(7)> v
	1: h
	#=> :"do not show this result in output"

	2: c("lib/game.ex")
	#=> [Game]

	3: c "lib/game.ex"
	#=> [Game]

	4: r Game
	#=> {:reloaded, Game, [Game]}

	5: h(Stream)
	#=> :"do not show this result in output"

	6: h(:httpc)
	#=> :"do not show this result in output"

	:ok

I like how it shows you not just the commands I typed in previously, but also the results.  Even better, it refuses to show the results that are very lengthy. IEx is all about information density except when it's about information overload.  

You can rerun one of those lines by calling its number. Again, parenthesis are optional:

	iex(9)> v 4
	{:reloaded, Game, [Game]}
	iex(10)> v(4)
	{:reloaded, Game, [Game]}

IEx doesn't show you the command again. It just runs it, showing you the return value.


## And If You're Really Bored

I'll leave you with this crazy command:

	iex(11)> m
	:application                              /usr/local/lib/erlang/lib/kernel-2.16.3/ebin/application.beam
	:application_controller                   /usr/local/lib/erlang/lib/kernel-2.16.3/ebin/application_controller.beam
	:application_master                       /usr/local/lib/erlang/lib/kernel-2.16.3/ebin/application_master.beam
	:beam_a                                   /usr/local/lib/erlang/lib/compiler-4.9.2/ebin/beam_a.beam
	:beam_asm                                 /usr/local/lib/erlang/lib/compiler-4.9.2/ebin/beam_asm.beam
	:beam_block                               /usr/local/lib/erlang/lib/compiler-4.9.2/ebin/beam_block.beam
	:beam_bool                                /usr/local/lib/erlang/lib/compiler-4.9.2/ebin/beam_bool.beam
	:beam_bsm                                 /usr/local/lib/erlang/lib/compiler-4.9.2/ebin/beam_bsm.beam
	:beam_clean                               /usr/local/lib/erlang/lib/compiler-4.9.2/ebin/beam_clean.beam
	[...]

The `m` command shows all the loaded modules currently available, including all the standard Elixir and Erlang modules, as well as all the ones you've attached.  It even gives you the BEAM file where it's defined and where that BEAM is.  This is what I was referring to earlier in talking about information overload.  Until you need to find some specifically, this is more than you'll likely need right now.


## To The Egress

You can exit out of IEx when you're done by hitting `CTRL-C` twice.  If you'd like something ridiculously lower level that likely will be meeaningless to you, hit `CTRL-C` once and follow it up with `i` for a lot of Key Value pairs that I won't pretend to understand.

## OK, One More Trick

There is more to IEx that maybe you'll want to use in the future. If you're interested in language design, try typing `t` or `s` with a module name and see what you get

	iex(24)> t Stream
	@type acc() :: any()
	@type element() :: any()
	@type index() :: non_neg_integer()
	@type default() :: any()

	iex(25)> s Stream
	@spec after(Enumerable.t(), (() -> term())) :: Enumerable.t()
	@spec chunk(Enumerable.t(), non_neg_integer()) :: Enumerable.t()
	@spec chunk(Enumerable.t(), non_neg_integer(), non_neg_integer()) :: Enumerable.t()
	@spec chunk(Enumerable.t(), non_neg_integer(), non_neg_integer(), Enumerable.t() | nil) :: Enumerable.t()
	@spec chunk_by(Enumerable.t(), (element() -> any())) :: Enumerable.t()
	@spec drop(Enumerable.t(), non_neg_integer()) :: Enumerable.t()
	@spec drop_while(Enumerable.t(), (element() -> as_boolean(term()))) :: Enumerable.t()
	@spec each(Enumerable.t(), (element() -> term())) :: Enumerable.t()
	[...]

You've likely seen some of this [in the docs](http://elixir-lang.org/docs/master/Stream.html).

But that's way down the road, even for me. 

To watch an abbreviated version of this tutorial, check out [this three minute video](https://www.youtube.com/watch?v=bDEY94xY-lI) I put together this week to show off some of IEx's features.

<iframe width="420" height="315" src="https://www.youtube.com/embed/bDEY94xY-lI" frameborder="0" allowfullscreen></iframe>