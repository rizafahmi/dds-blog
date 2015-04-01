# The New Maps Module

The big change coming to v0.13 of Elixir is the addition of maps as a new data type.  Maps will ultimately replace records, so if you have any projects based on records, it's time to consider a rewrite.  This is a change dictated by Erlang's upcoming 17th version, which is [posting Release Candidates](http://www.erlang.org/news/67) as I type this.  

Neither Erlang's changes nor Elixir's version of them are complete yet. This is beta software, though I imagine it's nearly complete.  

That's my nice way of saying that some things might change between now and the time things are finalized and show up on the main websites.  Please don't blame me.

If you'd like to play along, you need to install the v0.13 branch of Elixir and the release candidate for Erlang 17.  [I posted instructions on how to do that here.](http://variousandsundry.com/cs/blog/2014/02/21/installing-elixir-v13/)


## What Does A Map Look Like?

[As Joe Armstrong pointed out](http://joearms.github.io/2014/02/01/big-changes-to-erlang.html), these maps are the same idea as hashes in Perl, or dictionaries in Python.  They use the `%` sigil in Elixir.

You have your choice of two syntaxes to create a map.  Here's the same map created in the two different ways, colons versus hash rockets:

	iex> user = %{fname: "Martha", lname: "Martha", occupation: "Flag-Maker"}
	%{fname: "Martha", lname: "Martha", occuptation: "Flag-Maker"}

	iex> user = %{:fname => "Martha", :lname => "Washington", :occupation => "Flag-Maker" }
	%{fname: "Martha", lname: "Washington", occupation: "Flag-Maker"}

To get a singular value out, the shortest/easiest thing to do is use dot notation:

	iex> user.occupation
	"Flag-Maker"
	iex> user.fname
	"Martha"


## A Brief Introduction to the Map Module

The functions to use for maps are all under the `Map` module.  They come from the `Dict` module, mostly, so they might look familiar to you.  I'm going to go through the simple ones for you in this tutorial.

### new()

What do you think this does?  I'll give you three guesses, and the first two don't count.

	iex> user2 = Map.new
	%{}


### has_key?(map, key)

If you want to see if there is a specific key in a map, here's where you can test it:

	iex> Map.has_key?(user, :lname)
	true
	iex> Map.has_key?(user, :lnames)
	false


### fetch(map, key)

For error handling, `fetch` is a better way of going rather than just using dot notation.  `Fetch` returns a tuple.  If the key is good, the first value is `:ok`.  If the key is no good, it returns `:error`.  If you're going with the dot notation when the key doesn't exist, it gets ugly:

	ex(31)> Map.fetch(user, :lname)
	{:ok, "Washington"}
	iex(32)> Map.fetch(user, :lnames)
	:error

	iex(36)> user.fname
	"Martha"
	iex(37)> user.fnames
	** (ArgumentError) argument error: %{fname: "Martha", lname: "Washington", occupation: "Flag-Maker"}

If you're doing pattern matching to determine the next step in your program, matching `:error` seems like a no brainer way to go.


### pop(map, key, default \\ nil)

Deletes the specified key from the map and returns its value as the first item in a tuple.  The second item in the tuple is the new map without that value.  

	iex> Map.pop(user, :fname)
	{"Martha", %{lname: "Washington", occupation: "Flag-Maker"}} 

This is non-destructive to the original map:

	iex> user
	%{fname: "Martha", lname: "Washington", occupation: "Flag-Maker"}


### put(map, key, value)

Adds a new key and value to the map.

	iex> user = Map.put(user, :teeth, "Real")
	%{fname: "Martha", lname: "Washington", occupation: "Flag-Maker", teeth: "Real"}


### put_new(map, key, value)

Adds a key and value to the map only if it's a new key.  If it's a key that already exists, map will ignore it.

	iex> user = Map.put_new(user, :teeth, "Enamel")
	%{fname: "Martha", lname: "Washington", occupation: "Flag-Maker", teeth: "Real"}

Nothing changes in the user there at all because the key already existed.

But if I had a new key and value, it sticks:

	iex> user = Map.put_new(user, :hair, "White")
	%{fname: "Martha", hair: "White", lname: "Washington", occupation: "Flag-Maker", teeth: "Real"}

Behind the scenes, here's what the Elixir code looks like:

	def put_new(map, key, val) do
		case has_key?(map, key) do
		  true  -> map
		  false -> :maps.put(key, val, map)
		end
	end

Straight forward, right?  If the map you're trying to add something new to already has that key, then `put_new` returns the existing map. Otherwise, it adds that key and value to the map (via the `put` function we just showed you) and returns that.


### delete(map, key)

As you might guess, this removes a key from the map, returning the hash without that pair:

	iex> user = Map.delete(user, :hair)
	%{fname: "Martha", lname: "Washington", occupation: "Flag-Maker", teeth: "Real"}

Bye-bye, hair!

If you try to delete a key that doesn't exist, Elixir won't throw an error message.  It just returns the same exact map back.


### split(map, keys)

This one returns a tuple of two maps.  The first is a map with all the keys you list in the `keys` parameter there. The second map is everything else in a single map.

	iex> Map.split(user, [:lname])
	{%{lname: "Washington"},
	 %{fname: "Martha", occupation: "Flag-Maker", teeth: "Real"}}

### empty(map)

Returns an empty, keyless map:

	iex> empty_user = Map.empty(user)
	%{}
	iex> empty_user
	%{}
	iex> user
	%{fname: "Martha", lname: "Washington", occupation: "Flag-Maker", teeth: "Real"}


### equal?(map, map)

Compares two maps to see if they have the same exact set of keys and values.  The response is either true or false.

	iex(118)> user
	%{fname: "Martha", lname: "Washington", occupation: "Flag-Maker", teeth: "Real"}
	iex(119)> Map.equal?(user, %{fname: "Martha", lname: "Washington", occupation: "Flag-Maker", teeth: "Real"} )
	true
	iex(120)> Map.equal?(user, %{fname: "George"})
	false


### to_list(map)

Obviously, this one turns your map into a list:

	iex(40)> Map.to_list(user)
	[fname: "Martha", lname: "Washington", occupation: "Flag-Maker", teeth: "Real"]

Starts looking a little there like a record, superficially...


## To Be Continued. .. 

That should be enough to get you started. You can add, delete, and create maps at this point. You can test them for certain traits, look for keys and values, and manipulate keys and values.  Simple data movements are within your grasp. 

There's more to it than just that, of course, and we'll get to those functions a little later. Plus, I'll rewrite the Deck code from previous Doses to use the new maps.  Stay tuned. . . 


## Additional Reading

 * [The Maps proposal for Elixir.](https://gist.github.com/josevalim/b30c881df36801611d13)
 * [Elixir Map Source Code](https://github.com/elixir-lang/elixir/blob/v0.13/lib/elixir/src/elixir_map.erl)
 * [Elixir Map Tests in the Source Code](https://github.com/elixir-lang/elixir/blob/v0.13/lib/elixir/test/elixir/map_test.exs) 
 * [Erlang 17.0-rc1 Release Announcement](http://www.erlang.org/news/67)
