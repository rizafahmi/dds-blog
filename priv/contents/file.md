# File Module

## Introduction

> This module contains functions to manipulate files.

Let's start with inspecting the `read(path)` function. Simple enough, this is how to use it:

	iex(1) > File.read("one.txt")
    
It will return:

	{:ok, "Hello \n"}
    
If the file is not found, it will return an error:

	iex(2) > File.read("FileNotExist.txt")
    {:error, :enoent}
    
Atom `:ok` or `:error` is great for Elixir's pattern matching best practice. But, in some cases, if you don't want status atom `:ok` or `error`, just add `!` after `read` and it will return the content of file without the `:ok` atom.

	iex(3) > File.read!("one.txt")
    "Hello \n"
    
But be careful, if the file doesn't exist, you will see something ugly :)

	iex(4) > File.read!("FileNotExist.txt")
    ** (File.Error) could not read file FileNotExist.txt: no such file or directory
    /home/user/bin/elixir/lib/elixir/lib/file.ex:221: File.read!/1

Another useful function in this module that I want to inspect is `write(path, content, modes // [])`. `path` is the location of your file to write. If the file does not exist yet, it will create a new one.  Otherwise, if the file exists, it will overwrite the file with the new content (but it also depends on what mode you are using). `content` is the content that you want to put in your file. `modes` is an optional variable that you can add a writing mode with, such as write, append, read, raw, etc. It then will return the status of the writing process. `:ok` signals success.  You will get a different [error message](http://elixir-lang.org/docs/stable/File.html#write/3) otherwise.

	iex(5) > File.write("three.txt", "Elixir are awesome language\n")
    :ok
    iex(6)> File.write("FileNotExist.txt", "Elixir are awesome language\n"
    :ok
    


## Sample Application

In this section, we will build a super simple application that does the following:

1. Reads two files, `one.txt` and `two.txt`,
2. Concatenates the contents of those two files.
3. Writes it to a third file, `three.txt`.

Let's get started!

###Read The Two Files

We will use Elixir's pattern matching to determine if reading the file returns `:ok`. But before that, we create a project using mix: 

	$> mix new Readwriteapp
    $> cd Readwriteapp

We will use [TDD](http://en.wikipedia.org/wiki/Test-driven_development) style, so let's try to run the test:

    $> mix test
    
Sure, it will pass. Copy or add *one.txt* and *two.txt* into `test/fixture` directory as a test fixture:

	$> mkdir test/fixture
    $> cp *.txt test/fixture/
    
Open `test/readwriteapp_test.exs` and write our first test:

	test "read the two files" do
    	assert Readwriteapp.read_file('test/fixture/one.txt') == "Hello, \n"
        assert Readwriteapp.read_file('test/fixture/two.txt') == "elixir world!\n"
    end
	
Next, run the test `mix test` and the result should be a failure:

	1) test read the two files (ReadwriteappTest)
     ** (UndefinedFunctionError) undefined function: Readwriteapp.read_file/1
     stacktrace:
       Readwriteapp.read_file('test/fixture/one.txt')
       test/readwriteapp_test.exs:5: ReadwriteappTest."test read the two files"/1

It's an `undefined function`, so let's make it pass. Open lib/readwriteapp.ex, and write our first function:

	def read_file(filename) do
    	{:ok, content} = File.read(filename)
        content
    end
    
Try to run the test again and it will pass:

	$> mix test
	.
	Finished in 0.1 seconds (0.1s on load, 0.01s on tests)
	1 tests, 0 failures
    
Yay! Our first win!

### Concat the contents

Now you should know the drill: first, we create the test case, then we make it pass by writing the function.

	test "concat the content of the two files" do
    	content_result = Readwriteapp.concat_file_content('test/fixture/one.txt', 'test/fixture/two.txt')
        
        assert content_result == "Hello, \nelixir world!\n"
    end
    
Now we write the function. In Elixir, we use `<>` to concat the strings.

	def concat_file_content(file_one, file_two) do
   		read_file(file_one) <> read_file(file_two)
    end
    
Run the test:

	$> mix test
	..

	Finished in 0.1 seconds (0.1s on load, 0.01s on tests)
	2 tests, 0 failures
    
Two dots equals two wins! One more coming...


### Write The Result File
Let's write our last test:

	test "write the result file with the content of one and two files" do
    	assert Readwriteapp.write_file('test/fixture/result.txt', 'test/fixture/one.txt', 'test/fixture/two.txt') == :ok
        assert Readwriteapp.read_file('test/fixture/result.txt') == "Hello, \nelixir world!\n"
    end

Quick! We don't have much time! Write the function:

	def write_file(destination_file, file_one, file_two) do
    	File.write(destination_file, concat_file_content(file_one), concat_file_content(file_two))
    end
  
If we run `mix test`, it will give you three dots!

	$> mix test
	...
	Finished in 0.1 seconds (0.1s on load, 0.01s on tests)
	3 tests, 0 failures

Last thing we need is to run the module from [elixir script](http://elixir-lang.org/getting_started/3.html). To do that, we go to the `ebin` directory, and add new file called `run.exs`:

	IO.inspect Readwriteapp.write_file("result.txt", "one.txt", "two.txt")
    
Then we can run the script using `elixir` command: `elixir run.exs`. The script will output something like this:

	{:ok, "Hello, \nelixir world!\n"}

If we try to read the resulting file, the result would be the same.

	$cat result.txt
    Hello, 
	elixir world!

If you have any comments, suggestions, or thoughts, they would be appreciated! If you like what you see here, please subscribe using the form below. See you next time!

The files are available in [github repository](https://github.com/rizafahmi/elixir-dose-file-module).


---

Reference:

* [Elixir docs](http://elixir-lang.org/docs/stable/File.html)
* [Elixir introduction to mix](http://elixir-lang.org/getting_started/mix/1.html)
* [Elixir scripting mode](http://elixir-lang.org/getting_started/3.html)