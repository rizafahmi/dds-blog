# Lists and Values

In programming a card game, I'm dealing with lots of lists.  The deck of cards is a list of 52 records. A player's hand starts as a list of five cards.  The discards pile starts as an empty list and has cards added to it as the game goes on.  The draw pile is a big list that is whittled away until there's nothing left.  I'm constantly taking cards on and off different lists.

In doing this, I've run across some situations where lists and values didn't get along in ways I was expecting.  Let's run through some of those now.  Load up `iex` and play along. Here's the data we'll work with:

	iex(1)> list1 = [1,2,3]
	[1, 2, 3]
	iex(2)> list2 = [4,5,6]
	[4, 5, 6]


## Adding a Value

If you want to make a new list by concatenating those two lists, use the `++` operator:

	iex(3)> list1 ++ list2
	[1, 2, 3, 4, 5, 6]

Here's the trick: You cannot add a single value to the front of the list in this way:

	iex(4)> 0 ++ list1
	** (ArgumentError) argument error
	    :erlang.++(0, [1, 2, 3])

It does work in the other order, though perhaps not in the way you'd like:

	iex(4)> list1 ++ 4
	[1, 2, 3 | 4]

That's not a pattern I want to deal with for my program, though. I'm sure there's a strong case to be made that it's the perfect solution to someone's problem somewhere, but this ain't it.

If you're trying to add a single value to a list, you have two options.  

To put the new value at the start of the list, treat it like a head and the list like its tail:

	iex(5)> [ 0 | list1 ]
	[0, 1, 2, 3]

If you want the card added to the end of the list, treat the single value like a list by putting it in list context with a pair of brackets:

	iex(6)> list1 ++ [4]
	[1, 2, 3, 4]


## Subtracting a Value

What about grabbing a single value off the list? In the case of a card game, we're always taking the top card, whether it's off the discard pile or off the draw (the pile of cards you pick up from if you can't match the top discard card.)  There are two ways to grab that first value, and they give different results:

	iex(7)> Enum.split(list1, 1)
	{[1], [2, 3]}


The `Enum::split/2` function splits a single list into two after the number of values given in the second parameter.

	iex(8)> Enum.first(list1)
	1

The `Enum::first/1` function merely returns the first value.  The list remains as it was and doesn't even get returned as a value.

So if you're only looking for the top value, use the `first` command.  If you're trying to keep track of the state of the stack of cards you're picking a card up from, use `split`.  Just remember that you're getting back two lists, not a value and a list. Adjust your code accordingly.


## Context is Everything

However, what if you just want a single value, but you also need the rest of the array. `Split` works, but the value you're looking for is in list context. You can use `first` again to effectively convert a single value list to be just a value.

	iex(9)> {list_short, rest_of_list} = Enum.split(list1, 1)
	{[1], [2, 3]}
	iex(10)> Enum.first(list_short)
	1


## Applying This To Cards

In writing Deck, I came across a situation where I used the same function to pull cards off the deck twice. I called it `Deck.deal_cards(deck, number_of_cards)`.  Inside of it was a simple `split` command to break the list into two lists at the position of the number being passed in.  This works great and makes perfect sense when reading the code for dealing out a group of cards.  When you're only dealing out one card, however, you don't want that single card to be a list.  You want it to be a single value - until you want to merge it with another list and treat it like a list.  Do you want to compare a single card to what's in your hand?  Do you want to add a single card to your hand?  Do you want to pull a card out of your hand and add it to the discard pile?

Sometimes, you want a value and sometimes it's more convenient to have a list.  Creating variable and function names is key in keeping all of this straight in your mind.  and, sometimes, you just have to wing it and do whatever it takes to make the test pass.  Sometimes, programming isn't pretty.

