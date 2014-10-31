Installation
============

Prerequisites
-----------------

 * Ruby 1.9 / Ruby 2.0. NOT compatible with Ruby 1.8.
 * This guide assumes that you already have mcollective working, and it probably helps to be familiar with it.
 * Redis database (a standalone process) is running and accessible. No setup is needed (at least in Fedora and Debian), just install the package and start the service.
 * Bundler (to install dependencies).
 * Mcollective version must be >= 2.6. Mcollective  must be compatible with the mcollective-client gem used in the project.

Setup mcollective
-----------------

First we need to get mcollective nodes sending registration details, and a single node to save these to redis using the registration agent. Then, the MCollective client on the mcomaster host needs to be configured to use this database for discovery, which will allow mcomaster to do fast discovery.

Example configs: https://github.com/ajf8/mcomaster/blob/master/mcollective/client.cfg https://github.com/ajf8/mcomaster/blob/master/mcollective/server.cfg

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

  * Configure the host, port and DB number for the registration agent (server.cfg). NOTE: you will need to make sure the redis gem is available to the ruby which is running this mcollective.

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

Install mcomaster from CentOS/RHEL 6 RPM (if you don't use this, from source instructions follow)
---------------

The following yum repositories are available:

  * Automated snapshot x86_64 el6 (recommended) - http://yum.mcomaster.org/snapshots/el6/x86_64/
  * Latest release (may be old) - http://yum.mcomaster.org/releases/latest/el6/x86_64/

The el6 RPM currently bundles all of its rubygem dependencies, isolated from your system ruby,
for ease of maintenance and installation. Because el6 ships with Ruby 1.8 which is not
supported (rolify, a dependency, dropped support), a Ruby 1.9.3 SCL (Software Collection) is used.

The Ruby SCL is kept seperate and will not interfere with any other version of ruby, including
the stock 1.8.

  * Install the SCL repository:

``` bash
# wget http://people.redhat.com/bkabrda/scl_ruby193.repo -O /etc/yum.repos.d/scl_ruby193.repo
```

  * Install the mcomaster repository:

``` bash
# cat >/etc/yum.repos.d/mcomaster.repo <<EOF
[mcomaster]
name=mcomaster
baseurl=http://yum.mcomaster.org/snapshots/el6/\$basearch
enabled=1
gpgcheck=0
EOF
```

  * Install mcomaster packages:

``` bash
# yum install mcomaster
```

  * Create the database:

``` bash
# su mcomaster
$ cd /usr/share/mcomaster
$ RAILS_ENV=production scl enable ruby193 "bin/rake db:reset"

```

  * And a first admin user:

``` bash
$ RAILS_ENV=production scl enable ruby193 "/usr/share/mcomaster/script/add_user.sh -u user -m user@example.com -p password"
```

Install mcomaster (from source)
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

  * And a first admin user:

``` bash
mcomaster$ RAILS_ENV=production script/add_user.sh -u username -p password -m 'email@domain.com'
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
mcomaster$ thin start --ssl
```
