# From Perl to Elixir: ListUtils

Elixir is a functional language with a Ruby look and feel.  Ruby is an object oriented language that borrowed a lot from Perl.

As an exercise, let's go back to Perl today and implement part of one of its built-in modules in Elixir.  We'll be looking at [Perl's List::Util module](http://perldoc.perl.org/List/Util.html), which has a fairly functional set of subroutines that share one thing in common: They take in an array and return a single value.  

## The Function: Sum

As usual, let's create a sample application, naming it after the module it will emulate. 

	mix new listutils
	cd listutils

We'll start with `sum` which, as you might have guessed, adds up the values of the array (or, in Elixir's case, the list).  We'll start with the test over in _test/listutils_test.exs_ :

	test "Find sum of values" do
		assert (Listutils.sum([1,2,3,4,5], 0) == 15)
	end

The idea here is to pass a list along with an accumulator to the function. We start with a sum value equal to 0.  We should also test what happens if we pass in an empty list, so let's add that, too:

	test "Sum of empty list is 0" do
		assert (Listutils.sum([], 0) == 0)
	end

The function we've defined here is `sum/2`, which takes a list and an accumulator's starting point.  We use 0 to start.  Seems logical.

Now, over in _lib/listutils.ex_, we begin to code:

	defmodule Listutils do

	    def sum([], total) do
	      total
	    end
	 
	    def sum([head | tail], total) do
	      sum( tail, total + head )
	    end

	end

When we run `mix test` now, magic happens:

	[AugieDB] ~/elixir/listutils $ mix test
	...

	Finished in 0.07 seconds (0.07s on load, 0.00s on tests)
	3 tests, 0 failures


##Red, Green, Must Be Time to Refactor!

There's one thing that bothers me in this solution.  Asking the programmer to pass in the accumulator's base value isn't necessary. If there's ever a case where the programmer wants to start at something other than zero, let them add that number in themselves.  Getting rid of that extra parameter makes for a far cleaner call to the function.

Let's rewrite our tests first:

	test "Find sum of empty list" do
		assert (Listutils.sum([]) == 0)
	end

	test "Sum of empty list is 0" do
		assert (Listutils.sum([1,2,3,4,5]) == 15)
	end

Let's rewrite `Listutils` to handle the new design of the code:

	defmodule Listutils do

	  def sum(list) do
	    sum(list, 0)
	  end
	 
	  defp sum([], sum) do
	    sum
	  end
	 
	  defp sum([head | tail], total) do
	    sum( tail , total + head )
	  end
	 
	end

We've changed the definitions of the two pre-existing functions to be private by defining them with `defp` instead of `def`.  The new public `sum/1` function takes a list of any size and passes it in to the private functions to do the work.  We've effectively added a middle layer to make the code easier to write and read from the other side of the fence.

It might take a bit more typing to handle the problem than with Perl, but Elixir's solution is elegant in its own way and an excellent learning example.

##One Last Refactor

You could also use the Enum.map function, which is a more idiomatic Elixir way of handling the problem. It's a massive simplification from everything you see above.

	defmodule Listutils do

		def sum(list) do		
			Enum.reduce(list, fn(x, acc) -> x + acc end)
		end

	end

Obviously, this is the preferred method of doing it, but far less instructive.  The `reduce/2` function -- a recent addition to Elixir -- doesn't require a starting value.  If you did want to use one, there's also a `reduce/3`, which includes the accumulator as the second parameter.

[Here are the docs for the Enum module](http://elixir-lang.org/docs/stable/Enum.html#reduce/2).

##One Difference

The Perl List::Utils module has a second subroutine named `sum0`.  In truth, that's what we wrote here.  The difference between `sum0` and `sum` is the return value for an empty list. In `sum`, the program returns _undef_.  With `sum0`, a zero is returned. That's the only difference.

##To Be Continued

Next time, we'll work at translating the rest of the List::Utils module. It'll go very quickly, because Elixir handles most of it for us already.

##One Last Elixir Note

[See the release notes from v0.9.0 last May.](http://elixir-lang.org/blog/2013/05/23/elixir-v0-9-0-released/) There's talk in there about how the Enumerable library switched from iterating over values to using reduce. It is a cleaner and more functional paradigm.  The write-up also shows how the recursive solution I proposed first in this article (essentially a map) would be automatically rewritten by Elixir into a reduce, anyway.
