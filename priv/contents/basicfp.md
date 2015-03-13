# Functional Programming Basic Features
<!--
metadata goes here: 12345
metadata two goes here: 456
-->

A couple week ago I read [this article](https://medium.com/@jugoncalves/functional-programming-should-be-your-1-priority-for-2015-47dd4641d6b9)  about why you should take a look at functional programming.
Well, when you read and follow this blog you already did. One part that interesting
about that article is the basic features of FP, which is:

1. First-class functions
2. Higher-order functions
3. Closure
4. Immutable state

This is good practice for us to learn the very basic of functional programming through Elixir. So let's start!



## First-Class Functions

The basic definition of first-class functions is simply that you can store functions into a variable. You can also passes the functions around and invoked from other functions. This also known as anonymous functions in Elixir to be specific.

Let’s see the example.

    add = fn num1, num2 ->
      num1 + num2
    end
    
    substract = fn num1, num2 ->
      num1 - num2
    end
    
    perform_calculation = fn num1, num2, func ->
      func.(num1, num2)
    end
    
    IO.inspect add.(1, 2)
    
    IO.inspect substract.(2, 4)
    
    IO.inspect perform_calculation.(5, 5, add)
    IO.inspect perform_calculation.(5, 5, substract)
    IO.inspect perform_calculation.(5, 5, fn a, b -> a * b end)

## Higher-Order Functions

Elixir not only lets you put functions into variables, but also allow you to pass functions as another function’s arguments. In mathematics, a higher-order function in general is a function that takes one or more functions as an input and or returns a function as an output as well.
This one feature are where Elixir’s power really starts to shine. You can do higher-order functions in other languages, but Elixir treats higher-order functions as a native and feel natural. Let’s call it first-class higher-order functions :)

For example, take a look at these code below:
  
    iex> square = fn x -> x * x end
    #Function<6.17052888 in :erl_eval.expr/5>
    iex> Enum.map(1..10, square)
    [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]

In the first line we define an anonymous function that take a number and square it and assigned to the variable called `square`. Then we use `Enum.map` that takes 2 arguments. The first is just sequence of numbers and the second argument is a function that will be apply to each element of sequence.

## Closures

Closure is a concept that has these attributes:

* You can pass it around (first-class functions)
* It remembers the values of all the variables that were in the scope when the function was created. It is then able to access those variables when it is called even though they may no longer be in scope.

        iex(1)> outside_var = 5
        iex(2)> print = fn() -> IO.puts(outside_var) end 
        iex(3)> outside_var = 6
        iex(4)> print.()
        5
    
As you can see, even though you changed `outside_var` value, the result still 5. That’s because we changed the value after we define the `print` function.

## Immutable State

Elixir are immutable. By being immutable, Elixir also helps eliminate common cases where concurrent code has race conditions because two different entities are trying to change a data structure at the same time. Let's see how Elixir being immutable.

    iex> tuple = {:ok, "hello"}
    {:ok, "hello"}
    iex> put_elem(tuple, 1, "world")
    {:ok, "world"}
    iex> tuple
    {:ok, "hello"}

But yes, you still can re-assign variable. In the background, Elixir still immutable but in the front Elixir looks like support mutable state. With this, Elixir being the best of both world: immutable and mutable.
And with this decision, Elixir can become 'bridge' for people who interested in
FP so they're not overwhelm with all the functionality stuff. At least they still sign and
re-assign variables like other languages.

    iex(1)> num = 22
    22
    iex(2)> ^num = 23
    ** (MatchError) no match of right hand side value: 23

    iex(3)> num = 23
    23

In the first line, we assign variable called `num` to number 22. Then we try to
match variable `num` which is 22 with 23. We do pattern matching here with **hat** (^)
char before variable, not re-assign value. And the last line of code is we rebound
variable `num` and re-assign it to 23 as a value. In this case, `num` is just a container for data and you can re-bind it to new data. When you re-bind it the old data will be promptly chucked by the runtime leaving your memory free to store new data.

As I mentioned above, at it's core Elixir still immutable and you have no worries about
side-effect of variable re-assignment. Let's see the code.

    defmodule Assignment do
        def change_me(string) do
            string = 2
        end
    end

We try to change any variable that will passing the function into 2. Let's see
when we run the these code.

    $ iex assignment.ex 
    Erlang/OTP 17 [erts-6.2] [source] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false]
    
    assignment.ex:2: warning: variable string is unused
    assignment.ex:3: warning: variable string is unused
    Interactive Elixir (1.0.2) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)> greeting = "Hello"
    "Hello"
    iex(2)> Assignment.change_me(greeting)
    2
    iex(3)> greeting
    "Hello"

First of all, Elixir compiler will complaint about `string` variable is unused.
Then we assign variable called `greeting` to string "Hello". Then we try to change
the `greeting` variable with `Assignment.change_me/1` function we've created before.
It then return 2. But if we check `greeting` variable, it's still prints out "Hello"
as the original value.



## References
* [https://medium.com/@jugoncalves/functional-programming-should-be-your-1-priority-for-2015-47dd4641d6b9](https://medium.com/@jugoncalves/functional-programming-should-be-your-1-priority-for-2015-47dd4641d6b9)

* [https://github.com/chrismccord/elixir_express/blob/master/basics/03_basics.md](https://github.com/chrismccord/elixir_express/blob/master/basics/03_basics.md)

* [http://en.wikipedia.org/wiki/Higher-order_function](http://en.wikipedia.org/wiki/Higher-order_function)

* [Introducing Elixir Book](http://shop.oreilly.com/product/0636920030584.do)

* [http://www.sitepoint.com/elixir-love-child-ruby-erlang/](http://www.sitepoint.com/elixir-love-child-ruby-erlang/)

* [http://www.sitepoint.com/functional-programming-pure-functions/](http://www.sitepoint.com/functional-programming-pure-functions/)

* [http://www.skorks.com/2010/05/closures-a-simple-explanation-using-ruby/](http://www.skorks.com/2010/05/closures-a-simple-explanation-using-ruby/)

* [http://natescottwest.com/elixir-for-rubyists-part-2/](http://natescottwest.com/elixir-for-rubyists-part-2/)

* [http://elixir-lang.org/getting_started/2.html](http://elixir-lang.org/getting_started/2.html)
