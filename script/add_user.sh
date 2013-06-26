#!/bin/sh
OLDPWD=$PWD
cd `dirname $0`/..
bin/rails runner "require 'mcomaster/add_user_cli'; AddUserCli.new.run()" $*
cd $OLDPWD
