Testing with Vagrant
====================

Prerequisites
-----------------

 * Ruby 1.9 / Ruby 2.0. NOT compatible with Ruby 1.8.
 * Bundler (to install dependencies).
 * Vagrant, http://www.vagrantup.com/downloads.html
 * Virtualbox 4.3,  https://www.virtualbox.org/wiki/Downloads
 * Internet connection without proxy. 

Install the gems dependencies
-----------------------------
To install the project gems dependencies use bundler
``` bash
localhost$bundle install 
```

Install the puppet forge modules
-------------------------------- 
This vagrant environment use some puppet modules
from puppetforge. 

We use r10k to install all the required modules. 

Use the following rake task to install the required
modules.
``` bash 
localhost$rake r10k:install
```

Start the Vagrant environment
-----------------------------

The vagrant configuration is on tools/vagrant directory. 

To start it: 

``` bash 
localhost$cd tools/vagrant
localhost$vagrant up 
```
After it finishes, open http://localhost:8080 on 
your web browser. 

Login: vagrant@example.com

Password: vagrant123


Some common Vagrant Commands
----------------------------

 * start the virtual machines 
``` bash 
localhost$vagrant up 
```
 * destroy the virtual machines
``` bash 
localhost$vagrant destroy 
```
 * status of the virtual machines
``` bash 
localhost$vagrant status 
```
 * ssh into machines,
``` bash 
localhost$vagrant ssh mcomaster
localhost$vagrant ssh middleware
localhost$vagrant ssh mcserver2
localhost$vagrant ssh mcserver1
```
 * run puppet against one machine
``` bash 
localhost$vagrant provision mcomaster
```
 
