# Migrating to Maps

It's not that big a stretch to go from a record to a map.  I rewrote one of my Elixir projects to accommodate the new data type and discovered it was easy.

Not surprisingly -- to those of you who've been reading this site for any time now -- I used [my Deck module](http://elixirdose.com/elixir-deck/) as practice.  It simulates a deck of cards where each card is a record.  For this exercise, I'll change those records to maps and see if there's any interactions that will need to be adjusted, as well.


## Redefining a Card

This is the original code to define and describe a single card:

		defrecord Card, suit: nil, rank: nil, points: nil do

		  def describe({ :no_card }) do
		    "No card exists"
		  end

		  def describe(record) do
		      "#{record.rank} of #{record.suit} (#{record.points})"
		  end

		end

This is not a module.  This is a record with a couple of functions along the way for good measure.  The first thing a map version of this code will need is a module definition, and then a way to properly create a card:

		defmodule Cardmap do

		  def create(rank, suit, points) do
						#  	%{:rank => rank, :suit => suit, :points => points}
		  	%{rank: rank, suit: suit, points: points}
		  end

		end

I included both ways of creating a map in this sample code, then commented out the hashrocket version. 

The function will return the map, whose creation is the last value touched by the function.

The rest of the original record had a method by which you could pretty print a card's definition:

	  def describe({ :no_card }) do
	    "No card exists"
	  end

	  def describe(card) do
		"#{card.rank} of #{card.suit} (#{card.points})"
	  end

Good news: No substantive change is needed.  I only changed the parameter from "record" to "card" in the second function because it made more sense that way.  

Using the dot notation like this works the same in maps as it does in records, so the guys of the module didn't need any changes.


## The Deck Module

`Deck` is already a module in the original version, and there'll be no change here.  Let's look at a couple of the functions in that module, though:

	  def create do
	    lc rank inlist ['Ace',2,3,4,5,6,7,8,9,10,'Jack','Queen','King'], 
	        suit inlist ['Hearts','Clubs','Diamonds','Spades'], 
	    do: Card.new rank: rank, suit: suit, points: init_points(rank)
	  end

This is the big one.  It creates the deck of cards, one card at a time.  The only line we'll need to rewrite, though, is the one that creates the new map. That's in the second `do` section.  Let's take a look:

	  def create do
	    lc rank inlist ['Ace',2,3,4,5,6,7,8,9,10,'Jack','Queen','King'], 
	      suit inlist ['Hearts','Clubs','Diamonds','Spades'], 
	    do: Cardmap.create( rank, suit, init_points(rank) )
	  end

 The one part of this that is less than elegant is that we're now counting on getting the order of the values in the parameter list correct.  They aren't named parameters as they were in the records definition.

 On the bright side, it encapsulates the data better.  The Deck shouldn't need to know how a Card is created. It should just pass the information the card needs to create an example of itself, right? Maybe this is too object oriented for a functional language, but I like the way this works.  You only know the card is a map instead of a record or a tuple because I named it that way because this is a tutorial, not production code.

The rest of the code will be easy to leave alone.  The biggest deal in this code is with the Decks. Dealing with adding and removing cards from the deck is the most frequent calculation, and that's just acting on a list.  Picking up on those cards' values, suits, and ranks doesn't change with maps. Dot notation works either way. It's the Deck list that's important here, not the type of data structure it's hiding behind the scenes.  That's all abstracted out.


## Additional Viewing

For more background on Maps, check out the [two free ElixirSips.com videos from Josh Adams](http://elixirsips.com/episodes.html), #54 and #55.

