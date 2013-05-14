Installation
============

Prerequisites
-----------------

 * This guide assumes that you already have mcollective working, and it probably helps to be familiar with it.
 * Redis database (a standalone process) is running and accessible. No setup is needed (at least in Fedora and Debian), just install the package and start the service.

Setup mcollective
-----------------

First we need to get mcollective nodes sending registration details, and a single node to save these to redis using the registration agent. Then, the MCollective client on the mcomaster host needs to be configured to use this database for discovery, which will allow mcomaster to do fast discovery.

  * On your mcollective nodes, copy the meta.rb registration agent to your
mcollective extension directory.

``` bash
mcomaster$ cp mcollective/registration/meta.rb /usr/libexec/mcollective/mcollective/registration/meta.rb
```

  * Enable the registration agent on ALL nodes with the following server.cfg settings:

``` ruby
registerinterval = 300
registration = Meta
```

  * And enable direct addresing on ALL nodes (also in server.cfg):

``` ruby
direct_addressing=1
```

  * You will need *one* mcollective node which receives the registrations and saves them in redis. This is probably the same host that is running mcomaster, but it doesn't have to be.

``` bash
mcomaster$ cp mcollective/agent/registration.rb /usr/libexec/mcollective/mcollective/agent/
```

  * Configure the host, port and DB number for the registration agent (server.cfg).

``` ruby
plugin.redis.host = localhost
plugin.redis.port = 6379
plugin.redis.db = 0
```

  * On the system which will run mcomaster, you should already have a client setup which can mco ping and run actions. Then configure the discovery agent, which will query the redis database for discovery data.

  It has been renamed from Discovery to Redisdiscovery because of naming conflicts with the redis driver.

``` bash
mcomaster$ cp mcollective/discovery/redisdiscovery.* /usr/libexec/mcollective/mcollective/discovery/
```

  And add the following settings to the client.cfg. The setting names are the same as are used in server.cfg. You only need to do this in the client.yml on the host running mcomaster. The default "mc" discovery method which works by broadcasting to the broker should still work.

``` ruby
plugin.redis.host = localhost
plugin.redis.port = 6379
plugin.redis.db = 0
default_discovery_method = redisdiscovery
direct_addressing = yes
```

Setup mcomaster
---------------

  * In the mcomaster tree, use bundler to install dependencies (gem install bundler if this command does not exist):

``` bash
mcomaster$ bundle install
```

  * copy the example application config, then configure the admin user, redis location

``` bash
mcomaster$ cp config/application.example.yml config/application.yml
mcomaster$ vim config/application.yml
```

  * Setup the database

``` bash
mcomaster$ cp config/database.example.yml config/database.yml
mcomaster$ RAILS_ENV=production rake db:reset
```

  * compile assets

``` bash
mcomaster$ rake assets:precompile
```

  * to start

``` bash
mcomaster$ rails server -e production
```

  alternatively, start with SSL

``` bash
mcomaster: thin start --ssl
```
