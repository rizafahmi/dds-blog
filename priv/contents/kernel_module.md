# Kernel Module

## Introduction

Today we're back to the basics. We will explore the most basic module in Elixir, the Kernel module. We will learn how to check data types in Elixir and how to convert them back and forth.

For starters, let's look at the data types Elixir offers.

## Data Types

Elixir has six common data types:

	iex> 1          # integer
	iex> 1.0        # float
	iex> :atom      # atom / symbol
	iex> {1,2,3}    # tuple
	iex> [1,2,3]    # list
	iex> <<1,2,3>>  # bitstring
    


## Data Types Checker

The common pattern for checking data types in Elixir is `is_<data_type>`. Here are some examples:

	iex> is_integer(1) 
    true
    
    iex> is_float(1)
    false
    
    iex> is_integer(1.0)
    false
    
    iex> is_float(1.0)
    true
    
    iex> is_integer("This is integer!")
    false
    
    iex> is_list("This is integer!")
    false
    
    
The functions return `true` when they are right, and `false` when they are wrong.

Here is the list of all the data type checker functions available:

* `is_atom`
* `is_binary`
* `is_bitstring`
* `is_boolean`
* `is_float`
* `is_integer`
* `is_list`
* `is_tuple`


## Sample Application 

Now it's time to create a simple application out of this module. We'll call our application "Type Checker."  It will do the following things:

1. Make sure we receive data. 
2. Tell us what data type the variable is. 

Let's get started:

### Receiving Data

As usual, we create a   new app using `mix`:

	$> mix new typecheckerapp
    $> cd typecheckerapp
    $> mix test
    
The test should pass.

Now it's time to make our first test case in `test/typecheckerapp_test.exs`:

	test "receive any data type" do
    	assert Typecheckerapp.receive_variable(25) ==  {:ok, 25}
    end


Run the test to make sure it fails (because we haven't created the function yet):

	$> mix test
	1) test receive any data type (TypecheckerappTest)
     ** (UndefinedFunctionError) undefined function: Typecheckerapp.receive_variable/1
     stacktrace:
       Typecheckerapp.receive_variable(25)
       test/typecheckerapp_test.exs:5: TypecheckerappTest."test receive any data type"/1
       
       Finished in 0.3 seconds (0.2s on load, 0.08s on tests)
	1 tests, 1 failures
    
`undefined function` is a good description. Now we create the function that returns `:ok` if we receive any data:

	def receive_variable(variable) do                            
    	{:ok, variable}                                                            
    end 
        
If we run the test again, it passes:

	$> mix test
    .

	Finished in 0.1 seconds (0.1s on load, 0.00s on tests)
	1 tests, 0 failures
    
We probably also want to make sure the function is able to receive `list`, `tuple`, and `atom`:

	test "receive any data type" do
    	assert Typecheckerapp.receive_variable([1, 2, 3]) == {:ok, [1, 2, 3]}
        assert Typecheckerapp.receive_variable({1, 2, 3}) == {:ok, {1, 2, 3}}
        assert Typecheckerapp.receive_variable(:data) == {:ok, :data}
    end
    
Run it, and it still passes, right?

What if we didn't give it any data at all? We should make that test case:

	test "did not receive any data" do
    	assert Typecheckerapp.receive_variable == {:error, "No data"}
    end

How can we solve this test case? We could use an `if` statement to check if the data exists or not. But no, we will use the Elixir way by adding the same function without any parameter:

	def receive_variable() do
    	{:error, "No data"}
    end
    
If we re-run the test again, it passes:

	$> mix test
	..
	Finished in 0.1 seconds (0.1s on load, 0.01s on tests)
	2 tests, 0 failures

Mission accomplished!

## Figuring Out The Data Type

Now we can take the variables and figure out what type they are. But first, we should create new test cases:

	test "check variable is integer" do
		{:ok, variable} = Typecheckerapp.receive_variable(25)
		assert Typecheckerapp.check_variable(variable) == {:ok, "You give us an integer"}
    end
    
    test "check variable is float" do
		{:ok, variable} = Typecheckerapp.receive_variable(25.15)
    	assert Typecheckerapp.check_variable(variable) == {:ok, "You give us a Float"}
    end
        
    test "check variable is tuple" do
		{:ok, variable} = Typecheckerapp.receive_variable({})
    	assert Typecheckerapp.check_variable(variable) == {:ok, "You give us a Tuple"}
   	end
    
    test "check variable is list" do
		{:ok, variable} = Typecheckerapp.receive_variable([1,2])
    	assert Typecheckerapp.check_variable(variable) == {:ok, "You give us a list"}
   	end
    
    test "check variable is an atom" do
		{:ok, variable} = Typecheckerapp.receive_variable(:some_atom)
    	assert Typecheckerapp.check_variable(variable) == {:ok, "You give us an atom"}
   	end

We use pattern matching to get the variables and output their data types.

That will be a lot of red if you run `mix test`. So we will make it green now. Elixir provides `cond` for this kind of problem.

	def check_variable(variable) do
    	cond do
        	is_integer(variable) == true -> {:ok, "You give us an integer"}
            is_float(variable) == true -> {:ok, "You give us a float"}
            is_tuple(variable) == true -> {:ok, "You give us a tuple"}
            is_list(variable) == true -> {:ok, "You give us a list"}
            is_atom(variable) == true -> {:ok, "You give us an atom"}
		end
   	end
    
Run it, and....

	$ mix test
	.......

	Finished in 0.1 seconds (0.1s on load, 0.00s on tests)
	7 tests, 0 failures
    
Voila!

Until next time!


## Reference
[Elixir Kernel Module](http://elixir-lang.org/docs/stable/Kernel.html)