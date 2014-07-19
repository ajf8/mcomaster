This is a collection of puppet modules modeled on foreman-installer.

It can currently:
  * Setup an mcollective server which sends registration details and
    also saves to redis. 
  * Sets up the mcollective client which mcomaster needs.
  * Install the latest mcomaster snapshot, ruby from the SCL,
    creates the database and adds an admin user.

It does not install a message queue or redis yet.

Enable/disable/reconfigure the modules in mcomaster_installer/answers.yaml

Run as root:

  # echo include mcomaster_installer | puppet apply --modulepath /path/to/mcomaster/installer
