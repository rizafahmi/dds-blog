# Elixir List Util

## Rewriting First

Elixir is influenced by Ruby which is influenced by Perl, which has some functional moments, itself, most notably with the built-in `List::Util` module.  I thought it would be a good exercise to translate some Perl code to Elixir.

## List::Util

	List::Util - A selection of general-utility list subroutines

This Perl module performs a few basic tasks that take an array and return a single value.

Most of the subroutines in `List::Util` are mirrored perfectly in Elixir. Most notable are `min`, `max`, and `shuffle`.  Each of those has an Elixir function in the `Enum` module wih the same name.

One proved a little trickier to me.  It turned out to be easy in the end, but getting there was a learning experience. 

 
## first BLOCK LIST

In Elixir terms, substitute 'function' whenever you see 'BLOCK'.  This subroutine returns the first value in an array that evaluates as being true in the BLOCK that it's passed to.

Let's start by creating our project in _mix_:

	mix new listutil
	cd listutil

Now we can create our test in _test/listutil_test.exs_:

	test "Find first value greater than 2" do
		assert ( Listutil.first([1,2,3,4,5], fn x -> x > 2 ) == 3 )
	end

At first, I was stumped. There's no `first` function in Elixir.  So I broke the problem into smaller parts.  First, I wanted to find the command to create a new list made up of items that evaluated to true in a given function. I found that with `Enum.filter`.  Then, I needed to return the first value from that list.  Maybe I could return the list's head?  Nope, even simpler, there's an `Enum.first`.

The irony being, I was recreating Perl's `first` subroutine using Elixir's `first` function that does something else completely.

You can put this code in _lib/listutil.ex_ and see that it works for yourself:

	defmodule Listutil do
		def first(list, func) do
	    	Enum.filter( list, func ) |> Enum.first
		end
	end

It starts by returning a list of only values that evaluate to true in the function, and then passes that list to the `first` function, which returns only the first value of the list.

As a bonus, we get to use Elixir's much-loved pipe operator with this, sending the filtered list to `first` to return the correct value.

As an exercise, you can use this line of code and, with the right function, recreate the `min` or `max` functions fairly easily.  (Hint: There is a `Enum.reverse/1` function you can pipe out to.)

## The Better Solution

Of course, the Enum module already has a function that perfectly mimics Perl's first subroutine. It's `find/2`, taking a list and a function to filter through it.

	defmodule Listutil do
	    def first(list, func) do
	      Enum.find( list, func )
	    end
	end


Run `mix test` again and you'll see that this works just as correctly.


## Better Testing

With the solution in mind, let's do stronger testing.  What if we wanted to test many possible comparison functions for the list we're passing into `Listutil.first`? The answer is in a concept I had a tough time wrapping my head around until I realized it was the perfect solution to this problem: *Parameterized functions*, where a function can return a function, as described in Dave Thomas's "Programming Elixir" book.  (Look in Chapter 5.)

    test "Find first truthy value greater than x in a 1 to 5 list" do
      test_vals_over = fn x -> (fn n -> n > x end) end
      assert (Listutil.first([1,2,3,4,5], test_vals_over.(0) ) == 1)
      assert (Listutil.first([1,2,3,4,5], test_vals_over.(1) ) == 2)
      assert (Listutil.first([1,2,3,4,5], test_vals_over.(2) ) == 3)
      assert (Listutil.first([1,2,3,4,5], test_vals_over.(3) ) == 4)
      assert (listutil.first([1,2,3,4,5], test_vals_over.(4) ) == 5)
    end

The functions being passed in will now look something like this as they are evaluated:

	fn n -> n > 0 end
	fn n -> n > 1 end
	fn n -> n > 2 end
	fn n -> n > 3 end
	fn n -> n > 4 end

Is this good TDD programming technique?  No, not really.  But it's a great way to test a function that requires a different function to be pass through it with each call.

## Exercises Are Good For You

What I initially thought would be a good lesson for me in learning functional programming turned out to be an exploration of Elixir's Enum module functions. Coming up with little projects like this are great for learning a new language.  They give you a goal.  They start you off with something you probably already understand.  It's good practice and it'll make you a better programmer.

## Resources

 * [Perl List::Util module](http://perldoc.perl.org/List/Util.html)
 * [Elixir Enum docs](http://elixir-lang.org/docs/stable/Enum.html)
 * ["Programming Elixir" by Dave Thomas](http://pragprog.com/book/elixir/programming-elixir)