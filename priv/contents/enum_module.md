# Enum Module

## Introduction
> Enum module provides a set of algorithms that enumerate over collections.


The Enum module is an exciting one to discuss. It is a good way to learn about recursion, which is the main advantage of using a functional programming language like Elixir.

There's a lot of material in the Enum module. This article will look into simple functions, not _all_ of them. Still, it will be two part article. This week, we will discuss `min, max, concat, count, drop, each, empty?, fetch, and join.` 

Enum is usually used for looping through lists or arrays, since Elixir doesn't have loops.

## Min

`min(collection)` will return the minimum value of the `collection` given. It raises EmptyError if the `collection` is empty.

	iex> Enum.min([1, 2, 3, 4, 5])
    1
    

## Max

Opposite to `min`, `max(collection)` returns the maximum value.  It also raises EmptyError if the collection is empty.

	iex> Enum.max([1, 2, 3, 4, 5])
    5

	iex> Enum.max( [] )
	** (Enum.EmptyError) empty error
    	(elixir) lib/enum.ex:1146: Enum.reduce/2


## Concat
    
`concat(left, right)` will concatenate the enumerable on the right with the enumerable on the left.

This function produces the same results as the ++ operator for lists.

	iex> Enum.concat([1..3, 6..10])          
	[1, 2, 3, 6, 7, 8, 9, 10]
    

## Count
`count(collection)` will return the collection's size.  If the list is empty, it'll return a 0.

The usage is simple enough:

	iex> count([3, 4, 5])
    3
    
    iex> Enum.count( [] )
	0

## Drop
`drop(collection, count)` will delete the first `count` items from `collection`.

	iex> Enum.drop([1, 2, 3], 2)          
	[3]
    
What if the `count` is bigger than the size of the collection? It will return an empty collection.

	iex> Enum.drop([1, 2, 3], 10)           
	[]



## Each

If you want to apply some function to every item in a collection, you should use `each(collection, fun)`. For example, let's say we have a collection of strings and we want to print every item:

	iex> my_col = [33, 34, 36, 40, 2]
    iex> Enum.each(my_col, fn(x) -> IO.inspect x end)
	33
	34
	36
	40
	2
	:ok

This function will not change the `my_col` collection. If you print `my_col` after running `each` it will be the same as before:

	iex> my_col
    [33, 34, 36, 40, 2]
    
If you want to change the collection, please see the `map` function.

## Empty?

`empty?(collection)` will return `true` if the `collection` is empty and `false` if not.

	iex> Enum.empty?([])
    true
    iex> Enum.empty?([1, 2, 3])
    false


## Fetch

If you want to get one item out of a collection, use `fetch(collection, n)`. It starts with 0 and will return `{:ok, element}` if found, otherwise `{:error}`.

	iex> Enum.fetch([100, 110, 120], 0)
    {:ok, 100}
    iex> Enum.fetch([100, 110, 120], 1)
    {:ok, 110}
    iex> Enum.fetch([100, 110, 120], 2)
    {:ok, 120}
    iex> Enum.fetch([100, 110, 120], 3)
    {:error}
    

## Join
`join(collection, joiner // "")` will join `collection` with `joiner`. `joiner` can be binary or a list, and the result will be of the same type as `joiner`. If joiner is not passed at all, it defaults to an empty binary.

	iex> Enum.join([1, 2, 3])
    "123"
    iex> Enum.join([1, 2, 3], "\n")
    "1\n2\n3"
    
# Sample Application

Let's make a simple application to leverage our learning process. The application will give detailed information about a given list.


## Creating new project

Let's start our journey through the Enum module by creating a new project:

	$> mix new enumapp
    $> cd enumapp
    $> mix test
    Compiled lib/enumapp/supervisor.ex
	Compiled lib/enumapp.ex
	Generated enumapp.app
	.

	Finished in 0.1 seconds (0.1s on load, 0.01s on tests)
	1 tests, 0 failures
    
Then we step through to our first feature.

## Check For Empty List
First things first, we need to check if the list given is not empty before we do list operations with Enum. For this purpose, let's assume we already have a list of integers: `[10, 5, 7, 119]`

	test "Check if the list is empty" do
		list_given = Enumapp.get_list
		assert false == Enumapp.is_empty list_given
	end
    
Ok. Let's create our first function.

	def is_empty(list_input) do
    	Enum.empty? list_input
	end
    
Now run the test.

	$> mix test
	Compiled lib/enumapp.ex
	Generated enumapp.app

	.

	Finished in 0.1 seconds (0.1s on load, 0.00s on tests)
    1 tests, 0 failures

Cool!
    
## Get Minimum Member

The second value we're looking for will be the smallest member of the list. Let's make our test case for it.

	test "Return the smallest member of the list" do
  	list_given = Enumapp.get_list
  	assert 5 == Enumapp.get_min list_given
	end

We need to create two functions here. First, we create the `get_list` function that returns the list we mentioned earlier.  Then we create `get_min`.

	def get_list do
		[10, 5, 7, 119]
	end

	def get_min(list_input) do
		Enum.min list_input
	end

Let's run the test now.

	$> mix test

	..

	Finished in 0.2 seconds (0.2s on load, 0.02s on tests)
	2 tests, 0 failures
    

Now we can get the biggest value in our list of numbers. That's should be easy, right?! Slow down; we write the test case first, ok?

	test "Return the biggest member of the list" do
		list_given = Enumapp.get_list
		assert 119 == Enumapp.get_max list_given
	end
	
Then we create the function after we make sure that the test failed, as usual.

	def get_max(list_input) do
		Enum.max list_input
	end
    
And we run the test again to see the green light.

	$> mix test
	Compiled lib/enumapp.ex
	Generated enumapp.app

	...

	Finished in 0.1 seconds (0.1s on load, 0.01s on tests)
	3 tests, 0 failures
	
Cool! What's next?! Let's count the list.  First, a test:

	test "Return the number of list member" do
		list_given = Enumapp.get_list
		assert 4 == Enumapp.get_length list_given
	end	
    
Then, the code:

	def get_length(list_input) do
		Enum.count list_input
	end

	
Go run the test now.

	$>mix test

	....

	Finished in 0.1 seconds (0.1s on load, 0.01s on tests)
	4 tests, 0 failures
    

It feels good, doesn't it?!

That's it, folks! See you next time.

