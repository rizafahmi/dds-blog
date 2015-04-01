## Introduction
At the end of this article, we'll be able to create a simple guessing game using Elixir. To accommodate that, we need to learn the following:

* Getting user input
* Data Type conversion
* String Concatenation and interpolation
* Control flow
* Randomizing an integer

## Getting User Input
It's simple enough to use `IO.gets` like this:

	iex> IO.gets "Please enter your age "

It will return the user's input as a string. You could save it into a variable, if you wished.

## Data Type Conversion

In Elixir, we can convert certain data types into other data types. For example, we can convert string/binary into integer or float, atom to list, float to list, and much more. Check the documentation [here](http://elixir-lang.org/docs/stable/Kernel.html) to get the full list of data type conversions. The usage is simple:

    iex> binary_to_integer "22"
    22
	iex> binary_to_float "22.2"
	22.2

## String Concatenation and Interpolation

Let's say we have two strings that we want to join together. In Elixir, strings can be concatenated by using the `<>` operator.

 	iex> name = "Riza"
 	"Riza"
 	iex> IO.puts "My name is " <> name
 	My name is Riza
 	:ok

There is a better way to do this with string interpolation.

 	iex> IO.puts "Hello #{name}!!"
 	Hello Riza!!
 	:ok

## Control Flow

Elixir provides some extra control-flow structures to help in our daily work. Here are `if` and `unless`:

	iex> if true do
	iex>   "This will work"
    iex> end
    "This will work"

	iex> unless true do
	iex>   "This will never be seen"
    iex> end
    nil


## Randomize Number
Elixir doesn't have a random method (yet).  Luckily, Erlang does. So, in order to randomize an integer, we will use Erlang's `random` module and `uniform` method. This is how we randomize an integer between 1 to 10.

	iex> :random.uniform(10)
	5
	iex> :random.uniform(10)
	8

Notice the colon? That's how we call an `Erlang` module.

## Guessing Game Creation

After learning some techniques, now it's time to apply them. These are the steps we need in order to create our guessing game:

1. Generate one random integer.
2. Get user input.
3. Convert the user input into an integer.
4. Compare the random integer with user input.
5. Show the result.

Simple enough, right?! Now let's play!

### Generate One Random Integer

Before doing that, let's create our project and make sure the test suite works:

	$> mix new guessing game
	$> cd guessing_game
	$> mix compile
	Compiled lib/guessing_game.ex
	Compiled lib/guessing_game/supervisor.ex
	Generated guessing_game.app

	$> mix test
	.
	Finished in 1.0 seconds (0.9s on load, 0.07s on tests)
	1 tests, 0 failures

Cool! Now we have project to work with. Now we can create our first test. How can we test random number generation? I have no idea ^_^ 

So, we skip the random test and move forward to the next test. If you have suggestions regarding this problem, let me know.  (Leave a comment at the bottom of this article!)

### Get User Input
Moving on, let's create tests for checking user input. We want to limit the number that the user can input to between 1 and 10. So we should create a test for it:

	defmodule GuessingGameTest do
    	use ExUnit.Case

    	test "Checking valid user input" do
    		assert GuessingGame.check_user_input(5) == {:ok, 5}
    		assert GuessingGame.check_user_input(9) == {:ok, 9}
    		assert GuessingGame.check_user_input(10) == {:ok, 10}

    	end

    	test "Invalid user input" do
    		# Check user input bigger than 10
    		assert GuessingGame.check_user_input(11) == {:error, "11 is not valid number. Please input number between 1-10"}
    		assert GuessingGame.check_user_input(22) == {:error, "22 is not valid number. Please input number between 1-10"}
		end
        
	end


If we run the test, it will fail because we're not creating the `check_user_input` method just yet.

	$> mix test
	
	1) test Checking valid user input (GuessingGameTest)
     ** (UndefinedFunctionError) undefined function: GuessingGame.check_user_input/1
     stacktrace:
       GuessingGame.check_user_input(5)
       test/guessing_game_test.exs:5: GuessingGameTest."test Checking valid user input"/1

  	2) test Invalid user input (GuessingGameTest)
     ** (UndefinedFunctionError) undefined function: GuessingGame.check_user_input/1
     stacktrace:
       GuessingGame.check_user_input(11)
       test/guessing_game_test.exs:13: GuessingGameTest."test Invalid user input"/1

	Finished in 0.1 seconds (0.1s on load, 0.01s on tests)
	2 tests, 2 failures

Now, let's create the method:

	def check_user_input(number) when number <= 10 do
    	{:ok, number}
	end

	def check_user_input(number) do
    	{:error, "#{number} is not valid number. Please input number between 1-10" }
    end

Run the test again, and you'll see the green light!

	$> mix test
	..

	Finished in 0.1 seconds (0.1s on load, 0.01s on tests)
	2 tests, 0 failures

### Convert User Input
We need to convert the user's input into an integer. Why? Because `IO.gets` returns a string.  If we try to compare a number to a string, it will produce an error. Let's create the test first:

	test "Convert user input to integer" do
    	assert GuessingGame.convert_user_input("4") == 4
	end

Simply enough, we can use the `binary_to_integer` method from the Elixir Kernel Module. This is the method:

	def convert_user_input(string_input) do
    	binary_to_integer(string_input)
	end

Run `mix test`, and....

	$> mix test
	...
	Finished in 0.1 seconds (0.1s on load, 0.01s on tests)
	3 tests, 0 failures

Moving along...

### Compare Random Number With User Input

This is also tricky to test. We can assume that we got the random number by assigning a variable to a dummy number, then compare it to the user's input.

	test "Compare random number with user input that return true" do
    	random_number = 6
    	user_number = 6

    	assert GuessingGame.compare_numbers(random_number, user_number) == {:ok, user_number}

	end

	test "Compare random number with user input that return false" do
    	random_number = 7
    	user_number = 2

    	assert GuessingGame.compare_numbers(random_number, user_number) == {:error, "Wrong! Your guess #{user_number} but the number is #{random_number}" }
	end

Let's see the test:

	.

	1) test Compare random number with user input that return false (GuessingGameTest)
     ** (UndefinedFunctionError) undefined function: GuessingGame.compare_numbers/2
     stacktrace:
       GuessingGame.compare_numbers(7, 2)
       test/guessing_game_test.exs:33: GuessingGameTest."test Compare random number with user input that return false"/1

    2) test Compare random number with user input that return true (GuessingGameTest)
     ** (UndefinedFunctionError) undefined function: GuessingGame.compare_numbers/2
     stacktrace:
	GuessingGame.compare_numbers(6, 6)
       test/guessing_game_test.exs:25: GuessingGameTest."test Compare random number with user input that return true"/1

	..
	Finished in 0.2 seconds (0.1s on load, 0.02s on tests)
	5 tests, 2 failures

Let's make the world better by making it green:

	def compare_numbers(random_number, user_number) when random_number == user_number do
    	{:ok, user_number}
	end

    def compare_numbers(random_number, user_number) when random_number != user_number do
    	{:error, "Wrong! You guess #{user_number} but the correct number is #{random_number}" }
    end

If you run `mix test`, you'll see all green.

	$> mix test
	.....

	Finished in 0.1 seconds (0.1s on load, 0.00s on tests)
	5 tests, 0 failures

We finished the testing phase.  Now, let's create the user interface.

### User Interface

The test phase is finished, but we're not creating an application yet. Let's create an Elixir script called `guessing_game.exs` in an `ebin/` directory.

	defmodule GuessingGameUI do
  		IO.puts "Elixir Guessing Game\n"
  		IO.puts "--------------------\n\n"

	  	random_number = :random.uniform(10)

  		user_input = IO.gets "Enter your guess: "
	  	IO.inspect GuessingGame.convert_user_input(user_input)
	end

If we run the the script, what will happen?!

	$> elixir guessing_game.exs

	guessing_game.exs:5: variable random_number is unused
	Elixir Guessing Game
	--------------------

	Enter your guess: 3
	** (ArgumentError) argument error
    	:erlang.binary_to_integer("3\n")
    	lib/guessing_game.ex:19: GuessingGame.convert_user_input/1
   	guessing_game.exs:8: (module)	

It looks like the `binary_to_integer` method can't convert "3\n". I remember now that `IO.gets` will add an extra `\n` at the end of the characters. So before we do the conversion, we need to take care of that. Let's edit the test first by adding an extra `\n` and be sure it'll fail.

	test "Convert user input to integer" do
    	assert GuessingGame.convert_user_input("4\n") == 4
	end

	$> mix 
	...

  	1) test Convert user input to integer (GuessingGameTest)
     ** (ArgumentError) argument error
     stacktrace:
       :erlang.binary_to_integer("4\n")
       lib/guessing_game.ex:19: GuessingGame.convert_user_input/1
       test/guessing_game_test.exs:18: GuessingGameTest."test Convert user input to integer"/1

	.
	Finished in 0.2 seconds (0.1s on load, 0.02s on tests)
	5 tests, 1 failures

This is good practice! We recreated the error and now we can solve it by revising `convert_user_input` method.

	def convert_user_input(string_input) do
		string_input |> String.strip |> binary_to_integer
	end

Let's see what we've got going by running the script again:

	$> elixir guessing_game.exs                                                                                                                      
	guessing_game.exs:5: variable random_number is unused
	Elixir Guessing Game
	--------------------


	Enter your guess: 3
	3

Cool! Now we need to generate a random number to guess. To use the Erlang method `random`, we first need to seed it so the number will randomize:

	:random.seed(:erlang.now())
 	guest_number = :random.uniform(9) + 1

Then we check and convert the user's input using methods that we created earlier, and compare the numbers.

	{status, message} = GuessingGame.check_user_input(GuessingGame.convert_user_input(user_input))

Last, check if user input is right or wrong, then print the winning or losing message to the console:

	if status === :ok do
    	{compare_status, compare_message} = GuessingGame.compare_numbers(guest_number, message)

    	if compare_status === :ok do
      		IO.inspect "You are the winner!"
    	else
      		IO.inspect compare_message
    	end
  	else
    	IO.inspect message
  	end

This is the entire code for `guessing_game.exs`:

	defmodule GuessingGameUI do

  		IO.puts "Elixir Guessing Game\n"
  		IO.puts "--------------------\n\n"

  		:random.seed(:erlang.now())
  		guest_number = :random.uniform(9) + 1

  		user_input = IO.gets "Enter your guess: "

  		{status, message} = GuessingGame.check_user_input(GuessingGame.convert_user_input(user_input))

  		if status === :ok do
    		{compare_status, compare_message} = GuessingGame.compare_numbers(guest_number, message)

    		if compare_status === :ok do
      			IO.inspect "You are the winner!"
    		else
      			IO.inspect compare_message
    		end
  		else
    		IO.inspect message
  		end


	end


Let's try it:

	$> elixir guessing_game.exs
	Elixir Guessing Game
	
	--------------------

	Enter your guess: 4
	"Wrong! You guess 4 but the correct number is 7"

	$> elixir guessing_game.exs
	Elixir Guessing Game
	--------------------

	Enter your guess: 3
	"You are the winner!"

Yes, you are the winner by creating this game :)


## References

* [http://elixir-lang.org/docs/stable/IO.html](http://elixir-lang.org/docs/stable/IO.html)
* [http://elixir-lang.org/docs/stable/Kernel.html](http://elixir-lang.org/docs/stable/Kernel.html)
* [http://www.erlang.org/doc/man/random.html](http://www.erlang.org/doc/man/random.html)