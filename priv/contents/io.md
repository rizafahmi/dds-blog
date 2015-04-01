# Hello, ElixirDose

Hi, welcome to this site. In this first dose of your Elixir, I will introduce you to two [Elixir](http://elixir-lang.org) modules: **write** and **puts**.

###IO.write

> Writes the given argument to the given device. By default the device is the standard output. The argument is expected to be a chardata (i.e. a char list or an unicode binary).

> It returns :ok if it succeeds.

This is an example of the usage:

    defmodule Write do
    	def hello do
        	IO.write("Hello Elixir!")
        end
    end
    
And if you run it, Elixir will output something like this:

	Hello Elixir:ok    


###IO.puts
> Writes the argument to the device, similar to [write](http://elixir-lang.org/docs/stable/IO.html#write/2) module above, but adds a newline at the end. The argument is expected to be a chardata.

	defmodule Write do
    	def puts_hello do
        	IO.puts("Hello again, Elixir!")
        end
    end
    
The result will be:

	Hello again, Elixir!
	:ok
    
See the little difference?! 

See you next time!

---

Reference:

* [Elixir's write command](http://elixir-lang.org/docs/stable/IO.html#write/2)
* [Elixir's puts command](http://elixir-lang.org/docs/stable/IO.html#puts/2)