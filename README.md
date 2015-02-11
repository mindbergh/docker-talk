# Introduction to Docker and Fig

## Overview
- What is Docker?
- Docker fundamentals
- Fig
- 'Dockerising' for production
- Improving Development
- Limitations of Fig and Docker

## What is Docker?

[Docker](http://docker.com) allows you to compartmentalize your applications so
that development and deployment are much more straightforward.  You can think of
it as the free and easy way to set up best-practices production environments.

## Docker *FUN*damentals

Docker creates application `containers`, which you can think of as a super-light
virtual machine.

You can either use the prebuilt containers on the [Docker
registry](https://registry.hub.docker.com/) or modify your own.

These modifications are configured with a `Dockerfile` that lives in your
project.  While we'll go over the syntax later, here's the [official
documentation](https://docs.docker.com/reference/builder/).

Generally, a project will have several of these containers.

An example of a Dockerfile can be found [here](./Dockerfile).


## Fig

While Docker is very useful, it need orchestration for it to shine.  This is
provided by a service called [Fig](http://www.fig.sh/).  Fig is a set of scripts
that wrap around Docker to provide programmatic multi-app orchestration.

Fig is owned by Docker, and its functionality will be folded into Docker (as of
this talk it is in Alpha).

## 'Dockerising' for production

The best way to learn Docker is to use it!  To that end, we will convert
a web-app currently hosted on Heroku to a Docker and Fig project, then deploy it
to a fresh server from DigitalOcean that we will provision.

### Converting the application

Converting the application is relatively straightforward.  The details will be
specific to each project, but this is a brief overview of the project I will be
converting tonight.

#### Setting up Fig project

In the root of the project, we want to create a `fig.yml`.  Details on the
syntax of the file can be found [here](http://www.fig.sh/yml.html).

In it, we define the containers that will make up our project.  In our case,
I will be making a database container, an app server, and a static file server.

#### Mongo

We don't have to do anything else for the Mongo server.  Since we're using the
default upstream, we just note that the database will be available to our Node
instance at hostname `mongodb://db_1:27017/`.

#### Node

This requires us to write a Dockerfile.  We will specify the build directory,
then some other useful metadata.

#### Nginx

We will use this server to serve out our static files, which is better than
having Node.js serve them out.  This will then reverse-proxy our API connections
to the node container.

### Provisioning the server

I will be doing a very limited version of a server set-up.  For a safer setup than this, I recommend checking out [this article](http://plusbryan.com/my-first-5-minutes-on-a-server-or-essential-security-for-linux-servers).

I will be doing a subset of that article, in that I will set up a user account,
turn on the firewall, and update the system.  Then I will install git, Docker,
and Fig.  This is all you need to set up a deployment server.  Note that you can
definitely have more than one application per deployment server!  I have
a single production server for about five or six apps, you just need to put
something like Nginx in the middle to route the queries.  For our purposes, we
will just use the Docker app directly.

#### Get a server instance

While there are many solutions to this problem, I will do the easiest, which is
to use DigitalOcean.

Go to [DigitalOcean](https://www.digitalocean.com/), log in, and create an
Ubuntu droplet.  I add an SSH key so that I can just SSH directly from my
development machine.

#### Server security 101

First we're going to set up a user account for our server and set passwords.

```
passwd
adduser deploy
```

Then we're going to set up and turn on the firewall.

```
ufw allow 22 # SSH port
ufw allow 80 # HTTP port
ufw enable   # turn on firewall
```

Make sure to use `ufw allow` to open up any additional ports your server may
need (such as `443` for HTTPS).

Finally, we're going to let our `deploy` user have `sudo` access.

```
visudo
```

This should open your `sudoers` file in a text editor.  Comment out all existing user/group permissions and add the following lines:

```
root    ALL=(ALL) ALL
deploy  ALL=(ALL) ALL
```

You now have a server you can use to deploy your application!

#### Protip:

Docker runs a root-owned service.  The executable that we work with is a client
that connects to the service.  Therefore, we need sudo access to connect to it.
However, because this is very annoying, you can add yourself to the `docker`
user group to get around this.

Note: you need to be `root` to do this, or use `sudo`.

First, check that the group exists:
```
grep docker /etc/group
```

If nothing shows up (and therefore the group doesn't exist), create it.
```
groupadd docker
```

Then, add yourself to the group
```
usermod -a -G docker deploy
```

Make sure to log out and log back in to use these new privileges.

#### Install git, Docker, and Fig

We will only need three programs on this server.  First, we want `git` to be
able to checkout our code.

```
apt-get install git
```

Then, we will install Docker.  There are good guides for many systems on the
[Docker website](https://docs.docker.com/installation/#installation), but since
we're using Ubuntu I will use a script that they have packaged for this very
reason:

```
curl -sSL https://get.docker.com/ubuntu/ | sudo sh
```

Finally, we will get Fig.  It is released as a Python package, so the easiest
way to install it is to use `pip`.

First, we get `pip`.
```
apt-get install pip; # get pip from Ubuntu repositories
pip install -U pip;  # Use pip to get the latest version of itself
hash -r;             # Refresh command cache*

# *This is in case pip changes its location from the Ubuntu install
```

Finally, we install fig:
```
pip install -U fig
```

Running `fig --version` should verify that all is well.  You can now log out of
the root session and ssh in as `deploy`.

### Deploying the application (and updates)

The first thing you're going to want to do is do a `git clone` of your codebase.
Then, you're going to `cd` into your application directory, and run `fig up -d`.

That's it!

To make an update to the live code, you just need to do the following:

- `fig kill` to kill the currently running app.
- `git pull` to check out the latest and greatest code.
- `fig rebuild` will rebuild your containers if necessary.  This won't do anything if you didn't make any changes that would require a rebuild. (The nice thing about that is that it will preserve your database if you had one)
- `fig up -d` restarts the service

And you're back in business!

A couple of assumptions I'm making:

- As this is your production server, your code should not fail.  If it does, you should `git checkout` the last known working commit.  However, in theory you should be vetting your code.
- You're using something like `forever` or `nodemon` to restart your server if it fails at runtime.  Docker won't do this for you!

### Administration

While all of the `fig` functions are documented [here](http://www.fig.sh/cli.html), you should know the following:

- `fig up -d`: Start the fig app and daemonise it (so it runs even when you close your session)
- `fig logs`: View all of the logs for the entire application
- `fig logs %container%`: View all of the logs for a single container, for example `fig logs web`
- `fig run %container% %command%` Run a command in a container.  Most often, you're going to want to use it to run `bash` and poke around your container, for example `fig run static bash`

## Limitations of Fig and Docker

Fig and Docker are not perfect, nor are they a panacea.  Some things to consider
when using Fig and Docker in your application:

### They slow down intial development.

For Node, you don't just write a server.js and get cracking.  There is some
overhead for making a new project, which means you probably don't want to use it
for something temporary that you're hacking together, or that you won't deploy
elsewhere.

However, the benefits of its use means that it can make hackathons much less of
a headache.  By simplifying deployment, it means that you can spend less time
debugging Heroku, and more time writing nifty applications.

### Scaling is not automatic.

On the other end of things (at the enterprise level), scaling is not automatic.
A known complaint with Fig is that in order to make a copy of a container, you
must copy its configuration and link it in yourself.  Unlike some systems, which
allow you to quickly spin up ten more instances of your Node application and
link them in automatically, you have to do this yourself.  While Docker does
have this functionality, you shouldn't be using Fig, and should look into the
many other enterprise-level wrappers for Docker.  This is the drawback of using
a system as simple as Fig.

### Administration must be done over the command line.

This isn't really so much of a limitation as much of a disclaimer.  If you're
not comfortable with the terminal, Docker and Fig may not be right for you.  The
system GUI for Heroku may be a better fit for your use case.

## Conclusion

This talk was given on 11 February 2015 to the CMU Computer Club.
