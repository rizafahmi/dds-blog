# Phoenix Flying High: Deploying Phoenix The Final Part

## Introduction

If you follow along with Phoenix series in this  blog, I assume you have awesome web app ready spread to the world and start to get some traffic and profit :)

> We're using Phoenix version 0.4.1, postgrex version 0.6.0, ecto version 0.2.5 and Elixir version 1.0.0.

If you want to follow along, you can clone a repo from [github](https://github.com/rizafahmi/phoenix-jobs-part-4) or you always can simply use `phoenix new new_project` for this purposes.

Are you ready? This is how we will do:

1. Add exrm into our project,
2. Generate a release,
3. Preparing the production server,
4. Deploying our app into production server,
5. Expose the app to the world.

Let's do it!

## What Is exrm?

exrm is Elixir Release Manager. Well, that's explain everything. exrm sole mission is to help us release our Elixir applications.

How to use it? Well, that's what we will try to answer like, right now. Pretty easy, actually, just add it into our app dependency and we're good. we just need to add `{ :exrm, "~> 0.14.2" }` and let Elixir and [package manager](https://hex.pm) take care of the rest.

      defp deps do
        [
          {:phoenix, "0.4.1"},
          {:cowboy, "~> 1.0.0"},
          {:postgrex, "0.6.0"},
          {:ecto, "0.2.5"},
          {:exrm, "~> 0.14.10"}
        ]
      end

Now, let's run a simple command: `mix do deps.get, deps.compile`. It should pull down exrm and it's dependencies off course. After all fininsed, now if you run `mix` command, you'll see extra command from `exrm`.

    $ mix help
    mix                    # Run the default task (current: mix run)
    ...
    mix release            # Build a release for the current mix application.
    mix release.clean      # Clean up any release-related files.
    mix release.plugins    # View information about active release plugins
    mix run                # Run the given file or expression
    mix test               # Run a project's tests
    iex -S mix             # Start IEx and run the default task

Easy, right?!

## Get Ready, First Release Will Come

Open up `lib/phoenix_jobs_four.ex` and add `Router` as a children of our supervisor.

    defmodule PhoenixJobsFour do
      use Application
    
      def start(_type, _args) do
        import Supervisor.Spec, warn: false
    
        children = [
          worker(PhoenixJobsFour.Repo, []),
          worker(PhoenixJobsFour.Router, [], function: :start)
        ]
    
        opts = [strategy: :one_for_one, name: PhoenixJobsFour.Supervisor]
        Supervisor.start_link(children, opts)
      end
    end

Once we done that, we will not able to run `mix phoenix.start` anymore because it is trying to start your application's router after the application supervisor has already started it. If in case you still want to do it, you can run `iex -S mix phoenix.start` or simply `iex -S mix` will do it.

### Generate The First Release
Now it's the time to generate our very first Elixir release. Ready? Go to your terminal, then run `mix release`.

    $ mix release
    ==> Building release with MIX_ENV=dev.
    ==> Generating relx configuration...
    ==> Generating sys.config...
    ==> Generating boot script...
    ==> Performing protocol consolidation...
    ==> Conform: Loading schema...
    ==> Conform: No schema found, conform will not be packaged in this release!
    ==> Generating release...
    ...
    ==> Packaging release...
    ==> The release for phoenix_jobs_four-0.0.1 is ready!

Congratulations!!! The last line quiet important. If you see one, that mean our release is complete. You can see the it in `rel` directory.

    $ ls -l rel/phoenix_jobs_four/
    total 18800
    drwxrwxr-x 1 riza root        0 Nov 11 18:19 bin/
    drwxrwxr-x 1 riza root     4096 Nov 10 17:26 erts-6.2/
    drwxrwxr-x 1 riza root     4096 Nov 11 18:18 lib/
    drwxrwxr-x 1 riza root        0 Nov 10 17:42 log/
    -rwxrwxr-x 1 riza root 19238953 Nov 11 18:19 phoenix_jobs_four-0.0.1.tar.gz*
    drwxrwxr-x 1 riza root        0 Nov 11 18:18 releases/

`bin` contains generated executables for running our app. The bin/phoenix_jobs_four executable is what we will eventually use to issue commands to our app such as `$ rel/phoenix_jobs_four/bin/phoenix_jobs_four console` to try the release is actually working or not.

`erts-6.2` contains all necessary files for the Erlang runtime system, pulled from our build environment.

`lib` contains the compiled BEAM files for our applicaiton and all of our dependencies. 

`releases` is the home for our releases, being used to house any release-dependent configurations and scripts that `exrm` finds necessary for running our application.

Finally, the tarball is our release in archive form. We will transfer this file into the production server.

## Preparing The Production Server

I'll be using 'real' server to deploy our jobs app. For the learning purpose, I'll use [Digital Ocean](https://www.digitalocean.com/?refcode=ccb8fe03d9f6) VM (if you use the link to sign up, I will get referral credit). You can use literally everything else out there. It's your choice.

### Create The VM

Let's create one VM with 512MB RAM and 1 CPU (about $5/month in DigitalOcean) with Ubuntu 14.04 x64 as the OS. After you create the droplet, you'll receive the email regarding root password. Now you can login to the VM using SSH and change the password.

After that, we now can focus installing Erlang, Elixir and PostgreSQL database on our VM. But before we do it, let's update our system first.

    #> apt-get update && apt-get upgrade

Now we can start by install Erlang by install the required dependency packages.

    #> apt-get install build-essential libncurses5-dev openssl libssl-dev fop xsltproc unixodbc-dev
    
Then we download the latest Erlang available over erlang website and start compiling from source.

    #> curl -O http://www.erlang.org/download/otp_src_17.3.tar.gz
    #> tar xzfv otp_src_17.3.tar.gz
    #> cd otp_src_17.3
    #> ./configure && make && sudo make install

That's it! Now if you run `#> erl` you'll get Erlang REPL.

    Erlang/OTP 17 [erts-6.2] [source] [64-bit] [async-threads:10] [kernel-poll:false]

    Eshell V6.2  (abort with ^G)
    1>

You can exit the REPL by using `Ctrl-C` twice. Now we're ready to install Elixir. We will clone the Elixir repo from Github then compile it.
To be able to clone from git or github, we need git application, obviously.

    #> apt-get install git
    #> cd
    #> git clone https://github.com/elixir-lang/elixir.git
    #> cd elixir
    #> make clean test

If the tests pass, you are ready to go. Now, to be able to call Elixir and IEx REPL everywhere, we need to export `PATH`. We can do this inside our `.bashrc`.

    export PATH="$PATH:/root/elixir/bin"

After we do that, we should reload our `.bashrc` by running this command below.

    #> source ~/.bashrc

Then we finally can run IEx.
    
    #> IEx
    Erlang/OTP 17 [erts-6.2] [source] [64-bit] [async-threads:10] [kernel-poll:false]

    Interactive Elixir (1.1.0-dev) - press Ctrl+C to exit (type h() ENTER for help)
    iex(1)>

Cool! Now our server ready. It's time to transfer our app and deploy it in this very server.

[Installing Postgres]
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-14-04

[update the pg_hba.conf]

[migrate things]


## Deploying Our App Into Production Server

Back to our machine, now we need to transfer our app into the server that we prepared before.

    $> cd /home/elixir/phoenix_jobs_four
    $> scp rel/phoenix_jobs_four/phoenix_jobs_four-0.0.1.tar.gz root@your_digitalocean_vm_ip_address:

After a while, now let's login back to our production server via SSH. Then we extract the `phoenix_jobs_four-0.0.1.tar.gz` into a folder and that's it!

	$> ssh root@your_digitalocean_vm_ip_address
	$> mkdir -p /app
	$> cd /app
	$> tar xfz /root/phoenix_jobs_four-0.0.1.tar.gz

And now our `/app` directory structure looks like this:

	$> ls -l
	total 24
    drwxr-xr-x  6 root root 4096 Nov 19 19:50 ./
    drwxr-xr-x 23 root root 4096 Nov 19 19:49 ../
    drwxr-xr-x  2 root root 4096 Nov 19 19:50 bin/
    drwxr-xr-x  8 root root 4096 Nov 19 19:50 erts-6.2/
    drwxr-xr-x 24 root root 4096 Nov 19 19:50 lib/
    drwxr-xr-x  3 root root 4096 Nov 19 19:50 releases/

Let's start our app with this command.

	$> bin/phoenix_jobs_four start

Look like nothing happening, but in the backroung our app actually started. To check that out, use linux tools call ps.

	$> ps aux | grep phoenix_jobs_four
    root      1522  0.0  0.0  14864   788 ?        S    19:53   0:00 /app/erts-6.2/bin/run_erl -daemon /tmp/erl_pipes/phoenix_jobs_four/ /app/log exec "/app/bin/phoenix_jobs_four" "console"
    root      1523  2.8  2.1 314592 21396 pts/1    Ssl+ 19:53   0:00 /app/erts-6.2/bin/beam -- -root /app -progname app/bin/phoenix_jobs_four -- -home /root -- -boot /app/releases/0.0.1/phoenix_jobs_four -config /app/releases/0.0.1/sys.config -pa /app/lib/consolidated -name phoenix_jobs_four@127.0.0.1 -setcookie phoenix_jobs_four -user Elixir.IEx.CLI -extra --no-halt +iex -- console
    root      1556  0.0  0.0  11744   924 pts/0    S+   19:53   0:00 grep --color=auto phoenix_jobs_four

See? In case you need to debug at some point, you can use `remote_console`.

	$> bin/phoenix_jobs_four remote_console

What if you want to stop the app? Easy, just use `stop`.

	$> bin/phoenix_jobs_four stop
    ok

And after a while, if we check again with `ps` command, it will gone.

	$> ps aux | grep phoenix_jobs_four
	root      1784  0.0  0.0  11744   924 pts/0    S+   19:59   0:00 grep --color=auto phoenix_jobs_four

Ok, let's start our app again and expose the app to the world.

	$> bin/phoenix_jobs_four start

To ensure our app running, we can use `ping` command.

    $> bin/phoenix_jobs_four ping
    pong

If you see fancy message `pong`, we're good to go. If not, you'll see message something like this:

    $> bin/phoenix_jobs_four ping
    Node 'phoenix_jobs_four@127.0.0.1' not responding to pings.

Another way to testing it is by using `curl` command.

    $> curl http://localhost:4000

And if you see your website source print all over the terminal then you're awesome!


## Expose The App To The World

To expose our running app, we will need web server such as nginx or apache as our proxy. In this article we will use nginx as the proxy above our app.
Let's install it first.

    #> apt-get install nginx

Now let's set it up.

    #> touch /etc/nginx/sites-available/phoenix_jobs_four
    #> ln -s /etc/nginx/sites-available/phoenix_jobs_four /etc/nginx/sites-enabled
    #> vim /etc/nginx/site-available/phoenix_jobs_four

Fill the file with this content:

    upstream phoenix_jobs_four {
        server 127.0.0.1:4000;
    }
    server{
        listen 80;
        server_name jobs.elixirdose.com;
    
        location / {
            try_files $uri @proxy;
        }
    
        location @proxy {
            include proxy_params;
            proxy_redirect off;
            proxy_pass http://phoenix_jobs_four;
        }
    }

Now restart the nginx with `service nginx restart`. Pointing out the browser into the hostname, such as ip address or in this case `http://jobs.elixirdose.com`, and viola!

![jobs](http://photo.kilatstorage.com/jobs.png)

And if you have Elixir job, please don't hesitate to post it over [http://jobs.elixirdose.com](http://jobs.elixirdose.com).

Thank you for tuning in.


## Resources

* [https://github.com/lancehalvorsen/phoenix-guides](https://github.com/lancehalvorsen/phoenix-guides)
* [http://docs.basho.com/riak/1.3.0/tutorials/installation/Installing-Erlang/
http://elixir-lang.org/install.html](https://github.com/lancehalvorsen/phoenix-guides)
