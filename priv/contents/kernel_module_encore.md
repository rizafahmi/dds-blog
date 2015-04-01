# Kernel Module Part 2

## Introduction

In the comments section of our [last post](http://www.elixirdose.com/kernel-module), [http://twitter.com/cloud8421](@cloud8421) offered some suggestions to make our sample application better. Not only best practices, the suggestions will improve our app performance. You can see the proof in his [github repository](https://github.com/cloud8421/elixir-benchmark-test) based on our sample app. In this article, our goal is just to accommodate the suggestions and make our apps better.

So for today's topic, we will cover three things:
1. Guard-based implementation
2. Private functions
3. Elixir's |> operation

Thanks to [http://twitter.com/cloud8421](@cloud8421) for the inspiration :)

## Guard

Guard expressions provide a concise way to define functions that accept a limited set of values based on some condition.

Guard clauses let you define which version of a function to invoke depending on the values of the arguments a function receives. For example, if we want a function that acts differently depending on the data type it received, we could use a guard like this:

	def sum(a, b) when is_integer(a) and is_integer(b) do
		a + b
	end

	def sum(a, b) when is_lists(a) and is_lists(b) do
		a ++ b
	end


## Private Function

In Elixir, we have two types of function: regular and private. Functions defined with `def` will be available to be invoked from other modules while private ones defined with `defp` can only be accessed locally.

	iex> defmodule Math do
	iex>	def sum(a, b) do
	iex>		do_sum(a, b)
	iex>	end
	iex>	defp do_sum(a, b) do
	iex>		a + b
	iex>	end
	iex> end
	iex> Math.sum(1, 2)			#=> 3
	iex> Math.do_sum(1, 2) 	#=> ** (UndefinedFunctionError)

## Elixir's `|>` Operation

The pipeline operation is interesting one. `|>` takes the result of the expression on the left and uses it as the first parameter of the next function on the right. This operation is more or less similar to *nix `|` operator.

More interesting, this pipeline thing can transform your code beautifully!

Let's take a look at very simple example. We want to convert sentences into slugs for URL friendliness. The 'usual' way to do this is to take the string, strip it, downcase it and replace space with `-`.

	iex> String.replace(String.downcase(String.strip("This is the title we want to slugify\n")), " ", "-")

We could transform it into something like this:

	iex> string_to_slugify = "This is the title we want to slugify\n"
	iex> stripped_string = String.strip(string_to_slugify)
	iex> downcased_string = String.downcase(stripped_string)
	iex> slugified_string = String.replace(downcased_string, " ", "-")
	iex> IO.inspect slugified_string
	"this-is-the-title-we-want-to-slugify"

This is more readable code, I agree. But with the pipeline operator we could make it more beautiful:

	iex> "This is the title we want to slugify\n" |> String.strip |> String.downcase |> String.replace(" ", "-")

Even better, you could make it more sexy:

	iex> "This is the title we want to slugify\n"
					|> String.strip
					|> String.downcase
					|> String.replace(" ", "-")

Isn't that beautiful??!

# Sample, but beautiful app

[This is](https://github.com/rizafahmi/elixir-dose-typechecker/tree/part-one) what we have left of the [Kernel Module Article](http://www.elixirdose.com/kernel-module). To improve our app, we should do following:
1. Guard our app
2. Make some parts private 
3. Pipeline it up.

Ok, let's do it!

## Guarding our app

We can use guards in check_variable function. Instead of this:

	def check_variable(variable) do
		cond do
			is_integer(variable) == true -> {:ok, "You give us an integer"}
			is_float(variable) == true -> {:ok, "You give us a float"}
			is_tuple(variable) == true -> {:ok, "You give us a tuple"}
			is_list(variable) == true -> {:ok, "You give us a list"}
			is_atom(variable) == true -> {:ok, "You give us an atom"}
	end

we should do something like this:

	def check_variable(variable) when is_integer(variable), do: {:ok, "You give us an integer"}
	def check_variable(variable) when is_float(variable),   do: {:ok, "You give us a float"}
	def check_variable(variable) when is_tuple(variable),   do: {:ok, "You give us a tuple"}
	def check_variable(variable) when is_list(variable),    do: {:ok, "You give us a list"}
	def check_variable(variable) when is_atom(variable),    do: {:ok, "You give us an atom"}

Remember, we're not touching the test file, right?! So if we run `mix test`, what will happen???

	$> mix test
	........
	Finished in 0.2 seconds (0.1s on load, 0.01s on tests)
	8 tests, 0 failures

Magic!!!

## Make it private in some part

Next, we will create one more function that will be public, and make functions private. Before that, to keep a good practice, let's write the test cases first:

	test "testing receive and check is integer" do
		assert Typecheckerapp.receive_and_check(12) == {:ok, "You give us an integer"}
	end
	test "testing receive and check is float" do
		assert Typecheckerapp.receive_and_check(1.2) == {:ok, "You give us a float"}
	end
	test "testing receive and check is tuple" do
		assert Typecheckerapp.receive_and_check({}) == {:ok, "You give us a tuple"}
	end
	test "testing receive and check is list" do
		assert Typecheckerapp.receive_and_check([1,2]) == {:ok, "You give us a list"}
	end
	test "testing receive and check is atom" do
		assert Typecheckerapp.receive_and_check(:one_little_atom) == {:ok, "You give us an atom"}
	end
	test "testing receive and check is blank" do
		assert Typecheckerapp.receive_and_check() == {:error, "No data"}
	end

First, make sure it failed by running the test. Then, we create the function to make it pass:

	$> mix test
	....
	....
	Finished in 0.2 seconds (0.2s on load, 0.02s on tests)
	14 tests, 6 failures

We have six failures to fix. Let's fix the easiest one first.

	def receive_variable(), do: {:error, "No data"}

Run the test again, and we have fixed one problem. Five more to go!

	$> mix test
	....
	....
	Finished in 0.2 seconds (0.2s on load, 0.02s on tests)
	14 tests, 5 failures
	
Now for the tricky part:

	def receive_and_check(variable) do
		{:ok, received_var} = receive_variable(variable)
		check_variable(received_var)
	end

Run the test one more time...

	$> mix test
	..............
	Finished in 0.2 seconds (0.2s on load, 0.01s on tests)
	14 tests, 0 failures

All green! Cool!! Ok, now let's make all functions private except `receive_and_check`.

  defp receive_variable(variable) do
    {:ok, variable}
  end
  
  defp receive_variable() do
    {:error, "No data"}
  end
  
  defp check_variable(variable) when is_integer(variable), do: {:ok, "You give us an integer"}
  defp check_variable(variable) when is_float(variable),   do: {:ok, "You give us a float"}
  defp check_variable(variable) when is_tuple(variable),   do: {:ok, "You give us a tuple"}
  defp check_variable(variable) when is_list(variable),    do: {:ok, "You give us a list"}
  defp check_variable(variable) when is_atom(variable),    do: {:ok, "You give us an atom"}

Now, run the test again:

	$> mix test

	mix test

	1) test check blank variable (TypecheckerappTest)
     ** (UndefinedFunctionError) undefined function: Typecheckerapp.receive_variable/0

	[...]

	......

	Finished in 0.3 seconds (0.2s on load, 0.04s on tests)
	14 tests, 8 failures

Don't panic. It's all because the test called private functions, so the functions become unaccessible from outside of the module. What should we do? Just remove the test case. We didn't need that anyway. All the functionality is already covered by our new public `receive_and_check` function.

	$> mix test
	......

	Finished in 0.1 seconds (0.1s on load, 0.01s on tests)
	6 tests, 0 failures

## Piping it up

Our app is already beautiful enough, to be honest :) But since we want to keep practicing, we should change this part:

	def receive_and_check(variable) do
	    {:ok, received_var} = receive_variable(variable)
	    check_variable(received_var)
	end

into this:

	def receive_and_check(variable) do
	    {:ok, received_var} = receive_variable(variable)
	    received_var |> check_variable
	end

to accommodate the pipeline operation. And finally, run ```mix test``` and you've got yourself six green dots:

	mix test
	......
	Finished in 0.2 seconds (0.2s on load, 0.01s on tests)
	6 tests, 0 failures

I wonder how our new tweaked app performs in benchmarks. Maybe [@cloud8421](http://twitter.com/cloud8421) could do us another favor and update the benchmarks and share the results with us?!

One last thing, this code is available through [Github here](https://github.com/rizafahmi/elixir-dose-typechecker).


## References

[Kernel Module Article](http://www.elixirdose.com/kernel-module)
[String Module Doc](http://elixir-lang.org/docs/stable/String.html)
[Benchmark Github Repo](https://github.com/cloud8421/elixir-benchmark-test)
[Elixir Getting Started](http://elixir-lang.org/getting_started/3.html)
[Elixir Introduction Article](http://www.sitepoint.com/elixir-love-child-ruby-erlang/)
