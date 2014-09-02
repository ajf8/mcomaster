class mcomaster::config::mcollective::redis_gem($version = "latest") {
  if ! defined_with_params(Package['redis'], {'provider' => 'gem' }) { 
#     package{'redis':
#       provider => gem,
#       ensure   => $version,
#       notify   => Service['mcollective'],
#       require  => Class['custom_firewall::pre'],
#     }
    # some new bug in gem provider perhaps, use exec
    exec { 'gem_install_redis':
      command => '/usr/bin/gem install --include-dependencies --no-rdoc --no-ri redis',
      unless  => '/usr/bin/gem list --local | /bin/egrep -q ^redis',
    }
  }
}
