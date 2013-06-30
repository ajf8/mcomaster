# this file came from the foreman project

# Takes a key to lookup in the installation answers file
# - If it's a hash, declare a class with those parameters
# - If it's true or "true" declare the default parameters for that class
# - If it's false or "false" ignore it
# - Otherwise fail with error
#
define mcomaster_installer::yaml_to_class (
  $classname = ''
) {

  if $classname == '' {
    $realname = $name
  } else {
    $realname = $classname
  }

  if is_hash($mcomaster_installer::params[$name]) {
    # The quotes around $realname seem to matter to puppet's parser...
    $params = { "${realname}" => $mcomaster_installer::params[$name] }
    create_resources( 'class', $params )
  } elsif $mcomaster_installer::params[$name] == true {
    $params = { "${realname}" => {} }
    create_resources( 'class', $params )
  } elsif ! $mcomaster_installer::params[$name] or $mcomaster_installer::params[$name] == "false" {
    debug("${::hostname}: not including $name")
  } else {
    fail("${::hostname}: unknown type of answers data for $name")
  }

}
