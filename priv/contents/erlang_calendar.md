# The Erlang Calendar

Once you're done with the book learning of Elixir and get to programming challenges that might feel more like real world scenarios, you'll start to find that Elixir's core language is limited.  That's by design.  Erlang provides a wealth of tools at no cost to the programmer. It's worth familiarizing yourself with some of those.  There are wrapper libraries being worked on in different corners to help smooth things over just a bit, but using native Erlang functions can often be very easy, once you know a couple of techniques.

For instance, one of the things you might find yourself doing the most is dealing with dates and times.  Whether it's programming a blog or logging an event or naming a file, it's impossible to program for any length of time and not deal with dates and times.

Erlang gives us dates and times via its `calendar` module.  I'm going to cover a few parts of that module here today.  You can go down some pretty deep rabbit holes when talking about this topic, so I'm going to try hard to keep this at a high level.  Once you're comfortable with these functions, read [the whole calendar documentation](http://www.erlang.org/doc/man/calendar.html) and get an idea of some of the nitty gritty details for future reference.


## Date and Time

We'll be playing in `iex` to show some examples here this week. Feel free to type along:

	iex(1)> :calendar.local_time
	{{2014, 1, 30}, {21, 35, 24}}

To call an Erlang module, prepend it with a colon. In other words, make it look like an atom. (Riza showed another example of this in ["The Elixir Guessing Game"](http://elixirdose.com/elixir-guessing-game/) with the `:random` function.) Don't worry; Elixir will understand.  We'll start all of our Erlang references that way. 

Inside the calendar module, we have `local_time`, which responds with a two-part tuple of three-part tuples.  The first is the date and the second is the time.  As you can guess from just looking at it, the date is in _Year/Month/Day_ format, while the time runs _Hours/Minutes/Seconds_.

We can use pattern matching to make this more explicit, if you'd like:

	iex(2)> {{year, month, day}, {hour, minute, second}} = :calendar.local_time
	{{2014, 1, 30}, {21, 41, 4}}
	iex(3)> year
	2014
	iex(5)> second
	4

It might also be handy to save the values as a separate date and time for future calculations:

	iex(30)> {date, time} = :calendar.local_time
	{{2014, 1, 30}, {21, 41, 24}}
	iex(31)> date
	{2014, 1, 30}
	iex(32)> time
	{21, 41, 24}

The `local_time` value describes the time on the machine that's running your application. If you'd rather use the time along near Greenwich, England (i.e. UTC), go with `universal_time`:

	iex(8)> :calendar.universal_time
	{{2014, 1, 31}, {2, 45, 0}}

From some quick calculations in my head, I can tell that I'm in a time zone five hours behind UTC.


## Date Math

If you want to do some math with dates, Erlang recommends converting to Gregorian Days (they start at the first day of year 0) and then doing the math.

	iex(16)> :calendar.date_to_gregorian_days(date)
	735629

That's 735,000+ plus days since Year 0 began.  If I wanted to calculate the number of days between today and Christmas, I could do it this way:

	iex(17)> :calendar.date_to_gregorian_days({2014, 12, 25}) - :calendar.date_to_gregorian_days({2014, 01, 30})
	329

Better start my shopping!



## Week of the Year; Day of the Week

Want to know which week of the year this is?  Call `iso_week_number` without a parameter:

	iex(25)> :calendar.iso_week_number()
	{2014, 5}

If you specify today's date, you should get the same response:

	iex(19)> :calendar.iso_week_number(date)  # remember the pattern matching earlier for "date"?
	{2014, 5}

The return tuple tells us that this is the fifth week of the year 2014. That year value is important, since years can end mid-week.  Look what happened at the end of last year:

	iex(20)> :calendar.iso_week_number({2014, 01, 01})  # Wednesday
	{2014, 1}
	iex(21)> :calendar.iso_week_number({2013, 12, 31})  # Tuesday
	{2014, 1}
	iex(22)> :calendar.iso_week_number({2013, 12, 30})  # Monday
	{2014, 1}
	iex(23)> :calendar.iso_week_number({2013, 12, 29})  # Sunday
	{2013, 52}

[The ISO standard](http://en.wikipedia.org/wiki/ISO_week_date) starts the week with a Monday, so adjust your expectations accordingly. It's why the last week of 2013 ended on a Sunday, and the first week of 2014 began on the last Monday of 2013.

Along those same lines, if you want to ask for the day of the week, Monday is 1 and Sunday is 7:

	iex(27)> :calendar.day_of_the_week({2014, 01, 27}) # Monday
	1
	iex(28)> :calendar.day_of_the_week({2014, 01, 26}) # Tuesday
	7


## There's Much More

There's a [date validation function](http://www.erlang.org/doc/man/calendar.html#valid_date-1), a neat [converter to UTC](http://www.erlang.org/doc/man/calendar.html#local_time_to_universal_time_dst-1) that takes into account that one hour we repeat when leaving Daylight Savings, [a leap year checker](http://www.erlang.org/doc/man/calendar.html#is_leap_year-1), and more.

If you're looking for more, look towards GitHub for some options to improve the syntax. [Elixir-Datetime](https://github.com/alco/elixir-datetime), in particular, adds date shifting, some beginning time zone work, time intervals, and a few other handy functions.  A sister project, [Elixir-datefmt](https://github.com/alco/elixir-datefmt), adds easy formatting to dates and time.

If you'd prefer something else with a little more Ruby flavor, check out [Chronos](https://github.com/nurugger07/chronos), which gives you handy constructs like `Chronos.weeks_ago(5)` and `Chronos.yesterday`.  It's useful for testing purposes, and also gives you a familiar formatting tool set.

I'm sure we'll see more pop up as Elixir matures...
