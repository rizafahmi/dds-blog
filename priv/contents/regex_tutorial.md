# Regular Expressions

Regular expressions are a powerful language for matching text patterns. This article
will give a basic introduction to regular expressions and show how regexes work in Elixir.
Elxir's `Regex` module provides regular expression support.

In Elixir, a regular expression search is typically written as:

    match = Regex.run(runegex, string, options \\ [])

The `Regex.run()` method takes a regular expression pattern and a string, then
searches for the pattern within the string. If the search is successful, it will
return a list of results or a `nil` otherwise. The third argument `options` is for
optional arguments.

Let's see how it works with some code:

    iex(1)> str = "This is an example animal:cat!!!"
    "This is an example animal:cat!!!"
    iex(2)> match = Regex.run(~r/animal:\w\w\w/, str)
    ["animal:cat"]

As you can see above, a regex pattern in Elixir must written between `~r//`. You
can use extra options after the second `/` such as `u` for unicode, `i` for case
insensitivity, multiline, greedy etc.

## Basic Patterns

The real power of regex is that they can specify patterns, not just fixed characters.
Here are the most basic patterns which match single chars:

* Ordinary characters (a, X, 9, <) match themselves exactly. The 
meta-characters which don't match themselves because they have special meanings are:
. ^ $ + ? { [ ] \ | ( )
* . (period) will matches any single characters except new line `\n`
* \w will matches a single word character: a letter, digit, and underbar `_`. `\W`
will match any non-word character.
* \s will match a single whitespace character: space, newline, tab, and return.
`\S` will match any non-whitespace character.
* `\t \n \r` are tab, newline and return.
* \d is a digit from 0 to 9.
* ^ is start, $ is end.


## Basic Example

We will using some of the basic patterns above in this example:

    iex(3)> str = "Walrus"
    "Walrus"
    iex(4)> Regex.run(~r/lru/, str)
    ["lru"]
    iex(5)> str = "Walrus, Walrus!"
    "Walrus, Walrus!"
    iex(6)> Regex.run(~r/lru/, str)
    ["lru"]

If you notice in the second example with "Walrus, Walrus!" string, `Regex.run` will stop as soon it finds the first pattern. It will not continue to search for another example of that pattern.

Let's now see what happens when there is no match:

    iex(7)> Regex.run(~r/iii/, str)
    nil


## Repetition

This will get more interesting if we use some repetition patterns.

* `+` represents 1 or more occurences of the pattern to its left. For example `i+` is equal to one or more i's
* `*` represents 0 or more occurences of the pattern to its left.
* `?` represents 0 or 1 occurences of the pattern to its left.

Let's see the repetition pattern in action

    iex(7)> str = "Penguiiiin!"
    "Penguiiiin!"
    iex(8)> Regex.run(~r/ui+/, str)
    ["uiiii"]
    iex(9)> str = "Piinguiiiin!"
    ["Piinguiiiin!"]
    iex(10)> Regex.run(~r/i+/, str)
    ["ii"]

As you can see in the second example, it will return the first (from the left) pattern that it can find. Let's see another example:

    iex(12)> Regex.run(~r/\d\s*\d\s*\d/, "xx1 2   3xx")
    ["1 2   3"]
    iex(13)> Regex.run(~r/\d\s*\d\s*\d/, "xx12   3xx")
    ["12   3"]
    iex(14)> Regex.run(~r/\d\s*\d\s*\d/, "xx123xx")
    ["123"]
    iex(15)> Regex.run(~r/^u\w+/, "Penguiiiin!")
    nil
    iex(15)> Regex.run(~r/u\w+/, "Penguiiiin!")
    ["uiiiin"]

### Group  

The group feature of a regex allows you to pick out parts of a matching string. To do this, you add parenthesis `()` as grouping part. For example, if we want to extract the username and host separately from an email string, we can use groups:

    iex(16)> str = "rizafahmi@gmail.com"
    "rizafahmi@gmail.com"
    iex(17)> [email, username, host] = Regex.run(~r/(\w+)@([\w.]+)/, str)
    ["rizafahmi@gmail.com", "rizafahmi", "gmail.com"]
    iex(18)> email
    "rizafahmi@gmail.com"
    iex(19)> username
    "rizafahmi"
    iex(20)> host
    "gmail.com"


## Conclusion

That's it for this week. Regular expression is big topic to cover. We only used one method from the `Regex` module. But with this basic pattern and the `Regex.run` method, you have a lot to help you.
