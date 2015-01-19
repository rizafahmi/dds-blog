# Cowboy Tutorial Part 2: Creating Flat File Blog

If you follow ElixirDose blog, we did tried to create a very simple web framework [over here](http://elixirdose.com/post/lets-build-a-web-framework). In that article we did serve some markdown file as the example. In this article, we take the markdown example a little bit further by creating a drop dead simple flat file blogging engine. Because the first article is little bit outdated, we will learn together how to get started with [cowboy](https://github.com/ninenines/cowboy), a small, fast, and modular HTTP server written in Erlang.

Let's talk more detail about blogging engine that we will create. Our blogging engine will read through one folder that have several markdown files. No database whatsoever and it should be blazingly fast as a blog. The idea is to edit your content with your favorite text editor using markdown formatting, then you put on destination folder and viola! You've published your content. Quick and easy. We also support theming if someday we want to redesign the blog.

By creating this blogging engine, we will learn more about certain topics:

* Learn how to serve static files (images, css, javascript) with cowboy,
* Read and convert markdown file into html,
* Dynamically load markdown files depend on URL we requested on browser,
* Add themes and templating.

What we need to accomplish this project is:

* Elixir version 1.0.0 or later,
* Cowboy version 1.0.1,
* ExDoc as markdown tools

Ready, set go!

## Creating Elixir Project

We begin our journey by creating elixir project using `mix` tools.

  $> mix new dds_blog --sup

We named our project `dds_blog` after Drop Dead Simple Blogging Engine. And we add `--sup` argument to let `mix` know that we wanted to create an [OTP](http://learnyousomeerlang.com/what-is-otp) supervisor and [OTP](http://learnyousomeerlang.com/what-is-otp) application callback in our main `DdsBlog` module. You may learn more about [OTP here](http://learnyousomeerlang.com/what-is-otp).

Don't forget to change directory to our project folder that we've created.

  $> cd dds_blog

Now's the time to summon the cowboy.

## Add Cowboy To The Project

To make our application running, we'll need a server that can speak HTTP. We will use [Cowboy](https://github.com/ninenines/cowboy) for this case because it's [awesome](http://elixirdose.com/post/lets-build-a-web-framework).

To add Cowboy to our project, simply add Cowboy as the dependency inside `mix.exs` file.

  defp deps do
    {:cowboy, "1.0.0"}
  end

We need also add `:cowboy` under `applications` function while we still editing `mix.exs`.

  def application do

  end


## References

* http://learnyousomeerlang.com/what-is-otp
* https://github.com/ninenines/cowboy
