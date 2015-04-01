# More Maps

Here's a super short lesson to round out some of the Maps tutorial pieces from a couple weeks back named ["The New Maps Module."](http://elixirdose.com/the-new-maps-module/).  I mentioned how to create a new map and how to get information out of it.  I never outlined, however, how to update it or add a new key/value pair to it. 

First, let's create a new map:

		iex> car = %{wheels: 5, doors: 4, make: "BMW"}
		%{doors: 4, make: "BMW", wheels: 5}

There's your base. First, let's update it.  Let's choose a completely different make of automobile.  We'll change this BMW to a Mercedes:

		iex> car = %{ car | make: "Mercedes"}
		%{doors: 4, make: "Mercedes", wheels: 5}

You can not use this syntax, however, to add a new key/value pair:

		iex> car = %{ car | bumpers: 2 }
		** (ArgumentError) argument error
		    (stdlib) :maps.update(:bumpers, 2, %{doors: 4, make: "Mercedes", wheels: 5})

If you want to add a key/value pair, you're going to have to go to `Map.put_new`

		iex> car = Map.put_new(car, :bumpers, 2)
		%{bumpers: 2, doors: 4, make: "Mercedes", wheels: 5}

Just remember, if you try to add a key that already exists to a map, Elixir will ignore you:

		iex(18)> car = Map.put_new(car, :bumpers, 15)
		%{bumpers: 15, doors: 4, make: "Mercedes", wheels: 5}

You can also do some pattern matching with a map.

		iex> %{bumpers: number_of_bumpers} = car
		%{bumpers: 2, doors: 4, make: "Mercedes", wheels: 5}

		iex> number_of_bumpers
		2

Yes, of course you can match more than one thing at a time:

		iex> %{make: car_type, wheels: number_of_wheels} = car
		%{bumpers: 2, doors: 4, make: "Mercedes", wheels: 5}

		iex> number_of_wheels
		5

		iex> car_type
		"Mercedes"


## Related Reading:

* ["The New Maps Module"](http://elixirdose.com/the-new-maps-module/)
* ["Migrating to the New Maps"](http://elixirdose.com/maps-part-2/)