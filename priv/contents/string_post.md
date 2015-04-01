# String Module

## Introduction
> A String in Elixir is a UTF-8 encoded binary.

### String Length
`length(string)` will return the number of unicode graphemes in a UTF-8 string.

	iex(1)> String.length("ElixirDose")
	10
### Capitalize, Lowercase and Uppercase String
Elixir standard library provides us `capitalize(string)` to convert the first character in the given string to uppercase and the remaining to lowercase. `downcase(binary)` will convert a string to lowercase.  `upcase(binary)` will give you all uppercase characters.

	iex(2)> String.capitalize("elixir dose")
	"Elixir dose"
	iex(3)> String.downcase("Elixir Dose")
	"elixir dose"
	iex(4)> String.upcase("elixir dose")
	"ELIXIR DOSE"

As you can see in the example above, `capitalize` doesn't capitalize the first character of the second word ('dose' in this case). It capitalizes the first character only.

### Stripping String
If you want to remove trailing or leading unwanted characters, you can use `strip(string)` for the sake of simplicity. But if you need to remove specific characters, use `strip(string, char)`. For example you can remove spaces using `strip`:

    iex(5)> String.strip("  Yuhuuu!  ")
    "Yuhuuu!"

If you want to remove a trailing `\n`, use `strip(string, char)` like this:

	iex(6)> String.strip("Yuhuuu!\n", ?\n)
	"Yuhuuu!"

If you want to remove leading whitespace characters only, use `lstrip(string)`:

	  iex(5)> String.lstrip("  Yuhuuu!  ")
    "Yuhuuu!  "

Otherwise, you should use `rstrip(string)` for removing unwanted trailing whitespace characters:

    iex(5)> String.rstrip("  Yuhuuu!  ")
    "  Yuhuuu!"

### Slicing The String

To slice a string, use `slice(string, start, length)`. This is how to use it:

    iex(6)> String.slice("ElixirDose", 6, 4)
    "Dose"

This example says that we want to get a string starting from the sixth position and ending four characters later.

For more detail about character position and numbering, let's look at the image below:

{<1>}![string position](https://dl.dropboxusercontent.com/u/7154196/string.png)

Let's say I want to get 'Dose' string, but counting the characters from the end:

	iex(7)> String.slice("ElixirDose", -4, 4)
    "Dose"
    
Another way to slice is to use a range in `slice(string, range)`. The image guide above also applicable in this case. 

	iex(8)> String.slice("ElixirDose", 3..7)
	"xirDo"
    
Also we can go backwards and come out with the same result:

	iex(9)> String.slice("ElixirDose", -7..-3)
    "xirDo"

That's the confusing way to go, but it is possible, and you never know when it might be necessary...
    
## Sample Application

Here's the plan:

1. Remove the `\n` character at the end of the string.
2. Have fun with slicing characters, by slicing the string starting at the middle of the string up until the end.
3. Count the total characters left.

Lets get started!

### Starting The Project
	mix new funwithstringapp
    cd funwithstringapp
    mix test
    
The test will pass, since you haven't done anything yet.  Here we go to our first test scenario:

### Removing trailing `\n`

	test "removing newline character" do                                         
		assert Funwithstringapp.remove_trailing_char("Hello beloved reader\n") == "Hello beloved reader"                                                          
	end 

Run `mix test`.  Make sure it failed:

	  1) test removing newfile character (FunwithstringappTest)
     ** (UndefinedFunctionError) undefined function: Funwithstringapp.remove_trailing_char/1
     stacktrace:
       Funwithstringapp.remove_trailing_char("Hello beloved reader\n")
       test/funwithstringapp_test.exs:5: FunwithstringappTest."test removing newfile character"/1

	Finished in 0.1 seconds (0.1s on load, 0.02s on tests)
	1 tests, 1 failures
    
Now, make it pass by writing the function. This should be easy:

	def remove_trailing_char(string) do
    	String.strip(string)
    end
    
Run `mix test` again, and....

	$ mix test
	.
	Finished in 0.1 seconds (0.1s on load, 0.04s on tests)
	1 tests, 0 failures

One out of three.

### Slicing The String

We will split the string and get the last part. First, we find the character position at the middle of the string as the starting point:

	test "Get the middle char position" do
    	assert Funwithstringapp.middle_position == 10
    end
    
Ok, run `mix test` and guess what?! It failed, as it should. Let's write our second function to make this test pass:

	def middle_position(string) do
    	String.length(string) / 2
    	
    end
    
Run the test again, and.... You made it pass!

	$ mix test
	..

	Finished in 0.2 seconds (0.1s on load, 0.1s on tests)
	2 tests, 0 failures

Second, we slice it from that middle position.

	test "Slicing from middle position" do
    	testString = "Hello beloved reader\n"
        
    	assert Funwithstringapp.slicing_string(testString)
        
    end
    
Run `mix test`, if you like, to see that it failed.

Now, write the function:

	def slicing_string(string) do                                
       String.slice(remove_trailing_char(string), middle_position(string), String.length(string))                                    

	end

Run `mix test` and... It passes!

	$ mix test
	...

	Finished in 0.2 seconds (0.1s on load, 0.1s on tests)
	3 tests, 0 failures

### Count The Total Character

Last, but not least, we count the characters in the resulting string.

	test "Count the result string" do
    	assert Funwithstringapp.count_string_after_slicing("Hello beloved reader\n") == 10
    end
    
Then we write the function.

	def count_string_after_slicing(string) do
    	String.length(slicing_string(string))
	end

That was easy. Run `mix test` and you'll have the 4th dot.

	$ mix test
	....

	Finished in 0.2 seconds (0.1s on load, 0.09s on tests)
	4 tests, 0 failures

One last thing is to make an Elixir script to run it. Let's call it `run.exs` in the `ebin` directory:

	testString = "Hello ElixirDose Reader!\n"
	IO.inspect Funwithstringapp.slicing_string(testString)
    IO.inspect Funwithstringapp.count_string_after_slicing(testString)
    
Then run it `elixir run.exs` and you'll get:

	elixir run.exs 
	"Dose Reader!"
	12
	
Mission accomplished! Thanks for reading. And if you're not subscribed to ElixirDose, please do me the favor. You won't regret it!


### Reference

* [Elixir String Module Docs](http://elixir-lang.org/docs/stable/String.html)
