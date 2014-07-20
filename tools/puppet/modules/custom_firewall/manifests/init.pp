class custom_firewall inherits custom_firewall::common {
Firewall {
  before  => Class['custom_firewall::post'],
  require => Class['custom_firewall::pre'],
}

class { ['custom_firewall::pre', 'custom_firewall::post']: }

class { 'firewall': }


}
