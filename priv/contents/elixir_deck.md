# Elixir Deck

## Deck of Cards

I'm exploring Elixir this week by writing a card game.  The first task with such a program, of course, is devising a deck of cards: How to create a deck, and how to represent it.  What way will prove easiest?  Which data structure will be the easiest to work with later on for counting up points, looking for matches, etc.

The code all spilled out of an example [Dave Thomas gives in "Programming Elixir."](http://pragprog.com/book/elixir/programming-elixir)  He uses a deck of cards as an ideal example for list comprehension:

	import Enum
	deck = lc rank inlist '23456789TJQKA', suit inlist 'CDHS', do: [suit,rank]

	iex> deck = lc rank inlist '23456789TJQKA', suit inlist 'CDHS', do: [suit,rank]
	['C2', 'D2', 'H2', 'S2', 'C3', 'D3', 'H3', 'S3', 'C4', 'D4', 'H4', 'S4', 'C5',
 	'D5', 'H5', 'S5', 'C6', 'D6', 'H6', 'S6', 'C7', 'D7', 'H7', 'S7', 'C8', 'D8',
 	'H8', 'S8', 'C9', 'D9', 'H9', 'S9', 'CT', 'DT', 'HT', 'ST', 'CJ', 'DJ', 'HJ',
 	'SJ', 'CQ', 'DQ', 'HQ', 'SQ', 'CK', 'DK', 'HK', 'SK', 'CA', 'DA', ...]

If you haven't used a list comprehension (`lc`) before, think of it this way: 
	
**lc** _value_ **inlist** _list_of_values_**, do:** _something_with_list_

It loops over a list of values and returns something for each value.  It's exactly like `Enum.map/2` in that example, but has some extra flexibility built into it.  For example, you can use two lists and it'll be like creating an inner and outer loop.  So with an outer loop of 13 values and an inner loop of 4, you'll get your 52 card deck.  If you wanted to put a joker or two in there, you'd have to do that afterwards.

## Refining the Solution

I like things to be more descriptive, even if it means just a tad more typing at the top.  When I wrote a deck of cards in Ruby, I would create a `to_s` method to get a full listing of what a card is.  With Elixir, I think I'll short-circuit that a bit by referring to the card suits and ranks with their full names:

	iex> deck = lc rank inlist [2,3,4,5,6,7,8,9,10,"Jack","Queen","King","Ace"], suit inlist %W[Hearts Clubs Spades Diamonds], do: [suit,rank]
	[["Hearts", 2], ["Clubs", 2], ["Spades", 2], ["Diamonds", 2], ["Hearts", 3],
	 ["Clubs", 3], ["Spades", 3], ["Diamonds", 3], ["Hearts", 4], ["Clubs", 4],
	 ["Spades", 4], ["Diamonds", 4], ["Hearts", 5], ["Clubs", 5], ["Spades", 5],
	 ["Diamonds", 5], ["Hearts", 6], ["Clubs", 6], ["Spades", 6], ["Diamonds", 6],
	 ["Hearts", 7], ["Clubs", 7], ["Spades", 7], ["Diamonds", 7], ["Hearts", 8],...]

The new data set has the same structure, but uses the suit and rank names more literally.  I thought about turning all the names into atoms, which might be convenient for coding and testing, but a bit trickier in action to be translating the atom to the string with proper case too often.

If you prefer to use Tuples, then you need only change the brackets to curly braces:

	iex> deck = lc rank inlist [2,3,4,5,6,7,8,9,10,"Jack","Queen","King","Ace"], suit inlist %W[Hearts Clubs Spades Diamonds], do: {suit,rank}
	[{"Hearts", 2}, {"Clubs", 2}, {"Spades", 2}, {"Diamonds", 2}, {"Hearts", 3},
	 {"Clubs", 3}, {"Spades", 3}, {"Diamonds", 3}, {"Hearts", 4}, {"Clubs", 4},
	 {"Spades", 4}, {"Diamonds", 4}, {"Hearts", 5}, {"Clubs", 5}, {"Spades", 5},
	 {"Diamonds", 5}, {"Hearts", 6}, {"Clubs", 6}, {"Spades", 6}, {"Diamonds", 6},
	 {"Hearts", 7}, {"Clubs", 7}, {"Spades", 7}, {"Diamonds", 7}, {"Hearts", 8},...]

Keep tuples in mind, because they factor into the next part of this experiment.


## Records All the Way

The other big problem with dealing with a deck of cards in is counting how much they're worth.  Do we calculate it on the fly, or do we establish that right from the top?  Since each card has only value, we can go either way.  (If we were coding Blackjack, for example, we'd need to account for an Ace being either a 1 or an 11. That logic can't be worked out in advance.)

What if we made each card a record?  A record is effectively a tuple, so we have some experience getting there already.  

It requires a little extra work up front, but I think it's worth it.  Let's create a new mix application to handle all this.

	mix new deck
	cd deck
	mix test

Everything should pass that test.

Let's define our deck of cards in some way, for the sake of testing.  We'll set those tests up in _test/deck_test.exs_, of course:

	defmodule DeckTest do
		use ExUnit.Case
		test "52 cards in a deck" do
			assert ( length(Deck.create()) == 52 )
		end
	end

To match with that, we'll start editing _lib/deck.ex_ to define the record first:

	defrecord Card, suit: nil, rank: nil, points: nil

Do not put that inside the defmodule section.  This needs to be on its own outside of any other module declaration. Make it the first line of the file and bump the rest of the boilerplate down.

Record types look a lot like objects in object oriented programming.  They have a series of attributes that look a lot like key/value pairs.  In the definition of the record, you can set default value.  Here, I'll define the default as 'nil,' though we'll never actually use it.  Theoretically.

Now, let's create a deck, also in the _lib/deck.ex_ file:

	defmodule Deck do

	  # This part came with the mix init command.  We'll just leave it be...
      def start(_type, _args) do
        Deck.Supervisor.start_link
      end

	  def create do
	      lc rank inlist ['Ace',2,3,4,5,6,7,8,9,10,'Jack','Queen','King'], 
		  suit inlist ['Hearts','Clubs','Diamonds','Spades'], 
		  do: Card.new rank: rank, suit: suit, points: init_points(rank)
	  end

	end

You could write all that out on one line, but it's much more readable this way.  Don't test it yet, though: We need to do one more things first!


## The Points of the Matter

Note that I have a new function described at the end of the deck initialization there.  `init_points` needs to assign a number of points to each card, based on the card's known value.  

Let's write our tests for what values the cards should have:

   test "Giving the right point value to a card" do
     assert( Deck.init_points('Ace')   == 1)
     assert( Deck.init_points(2)       == 2)
     assert( Deck.init_points(10)      == 10)
     assert( Deck.init_points(5)       == 5)
     assert( Deck.init_points('Jack')  == 10)
     assert( Deck.init_points('Queen') == 10)
     assert( Deck.init_points('King')  == 10)
   end

Right now, I'm going on the theory that I'll always determine the point value of a card based on the value the `Card` record contains. This function should only need to run when the deck is created at the beginning of the game.

Defining `init_points` is simple to do in _lib/deck.ex_ as part of the `Deck` module:

	def init_points(points) when points > 1 and points < 11, do: points
	def init_points(points) when points == 'Ace', do: 1
	def init_points(_), do: 10

The series of functions whittles away at the possibilities with some guard clauses. The biggest group of cards has the point value that's the same as the card's rank. Those are all the number values.  We can't use `is_number` in a guard clause, sadly

I tested the Ace second because it's quicker to type than listing out all of the face card names.  Finally, the rest of the cards, by process of elimination, are face cards.  We don't care, at that point, which specific card it is. That's why we use the underscore to pattern match the value.  We're just going to throw it away.  We don't need to remember it, and we don't want to invoke the compiler's warning system at test time.

You can run `mix test` now and everything should pass.


## TESTING THE DECK

We now know we can create a deck with 52 cards and that each card will have the correct value for its rank.  Let's go a bit further to make sure we have the right number of cards for each rank and suit. We'll make two new functions to do this: `Deck::count_suit/2` and `Deck::count_rank/2`.  We'll write the tests first:

	test "13 Heart Cards in a deck" do
	  deck = Deck.create()
	  assert( Deck.count_suit(deck, 'Hearts') == 13 )
	  assert( Deck.count_suit(deck, 'Clubs') == 13 )
	  assert( Deck.count_suit(deck, 'Diamonds') == 13 )
	  assert( Deck.count_suit(deck, 'Spades') == 13 )
	end

	test "4 of each number in a deck" do
	  deck = Deck.create()
	  assert( Deck.count_rank(deck, 9)      == 4)
	  assert( Deck.count_rank(deck, 5)      == 4)
	  assert( Deck.count_rank(deck, 'Jack') == 4)
	  assert( Deck.count_rank(deck, 'King') == 4)
	  assert( Deck.count_rank(deck, 'Ace')  == 4)
	end

Run your tests now and you'll get about what you'd expect:

  1) test 4 of each number in a deck (DeckTest)
     ** (UndefinedFunctionError) undefined function: Deck.count_rank/2
     [...]
  2) test 13 Heart Cards in a deck (DeckTest)
     ** (UndefinedFunctionError) undefined function: Deck.count_suit/2

Let's write up those two functions in `lib/deck.ex' as part of the Deck module:

    def count_suit(deck, suit) do
      Enum.count(deck, fn(x) -> x.suit == suit end)
    end
 
    def count_rank(deck, rank) do
      Enum.count(deck, fn(x) -> x.rank == rank end)
    end

Go ahead and run `mix test` now to see your passing score. 

	Compiled lib/deck.ex
	Generated deck.app
	....

	Finished in 0.1 seconds (0.1s on load, 0.00s on tests)
	4 tests, 0 failures

If you do show any errors, go back and make sure you didn't typo anything.

[This code is available on GitHub.](https://github.com/augiedb/elixir-dose-deck)