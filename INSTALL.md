Installation
============


Setup mcollective
-----------------

First we need to get mcollective configured to use redis discovery, with the redis database populated using data from a registration agent on your nodes. The mcomaster web UI will use this for fast discovery. The below assumes you have mcollective working already, and are familiar with it.


  * On your mcollective nodes, copy the meta.rb registration agent to your
mcollective extension directory.

``` bash
mcomaster$ cp mcollective/registration/meta.rb /usr/libexec/mcollective/mcollective/registration/meta.rb
```

  * Enable the registration agent on the nodes with the following server.cfg settings:

``` ruby
registerinterval = 300
registration = Meta
```

  * And enable direct addresing on all nodes (also in server.cfg):

``` ruby
directaddressing=1
```

  * You will need *one* mcollective node which receives the registrations and saves them in redis.

``` bash
mcomaster$ cp mcollective/agent/registration.rb /usr/libexec/mcollective/mcollective/agent/
```

  * On the system which will run mcomaster, you should already have a client
setup which can mco ping and run actions. Then configure the discovery agent, which will query the redis database for discovery data.

  It has been renamed from Discovery to Redisdiscovery because of naming conflicts.

``` bash
mcomaster$ cp mcollective/discovery/redisdiscovery.* /usr/libexec/mcollective/mcollective/discovery/
```

  And add the following settings:

``` ruby
default_discovery_method = redisdiscovery
direct_addressing = yes
```

Setup mcomaster
---------------

  * In the mcomaster tree, use bundler to install dependencies (gem install bundler if this command does not exist):

``` bash
mcomaster$ bundle install
```

  * compile assets

``` bash
mcomaster$ rake assets:precompile
```

  * configure the admin user, redis location

``` bash
mcomaster$ cp config/application.example.yml config/application.yml
```

  * Setup the database

``` bash
mcomaster$ cp config/database.example.yml config/database.yml
mcomaster$ rake db:reset
```

  * to start

``` bash
mcomaster$ rails server -e production
```

  alternatively, start with SSL

``` bash
mcomaster: thin start --ssl
```
