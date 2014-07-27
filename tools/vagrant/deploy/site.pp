#class that manages /etc/hosts
class hosts_vagrant {
host{'middleware': 
  ip => "192.168.231.10"
}

host{'mcomaster': 
  ip => "192.168.231.11"
}
host{'mcserver01': 
  ip => "192.168.231.21"
}
host{'mcserver02': 
  ip => "192.168.231.22"
}
}
#class to configure all mcollective plugins
class mcollective_plugins { 

mcollective::plugin {'service': 
package => true
}
mcollective::plugin {'puppet':
package => true
}
mcollective::plugin {'package':
package => true
}
mcollective::plugin {'nettest':
package => true
}

mcollective::plugin {'nrpe':
package => true
}
mcollective::plugin {'iptables':
package => true
}

}


node /middleware/ {
  Yumrepo <| |> -> Package <| provider != 'rpm' |>
  #config package repository
  include puppetlabs
  #config /etc/hosts
  include hosts_vagrant
  #Config firewall rules
  include custom_firewall
  include custom_firewall::middleware
  include custom_firewall::redis
  #config mcollective default plugins
  class {'mcollective_plugins':
    require => [ Class['puppetlabs'], Class['custom_firewall::pre'] ]
  }
  #config redis
  class { '::redis': 
    version => '2.8.13', 
    redis_max_memory => '100mb',
    require => Class['custom_firewall::pre'],
  }
  #config mcollective
  class { '::mcollective':
    middleware       => true,
    middleware_hosts => [ 'middleware' ],
    require => Class['custom_firewall::pre'],
  }
  class {'::mcomaster::config::mcollective::server': 
    redis_host => "middleware"
  } 

}
node /mcomaster/ {
  Yumrepo <| |> -> Package <| provider != 'rpm' |>
  #config package repository
  include puppetlabs
  #config /etc/hosts
  include hosts_vagrant
  #config firewall 
  include custom_firewall
  class {'custom_firewall::mcomaster': 
    ports => [8080]
  }
  #config mcollective default plugins
  class {'mcollective_plugins':
    require => [ Class['puppetlabs'], Class['custom_firewall::pre'] ]
  }
  class { '::mcollective':
    client            => true,
    middleware_hosts => [ 'middleware' ],
    require          => Class['custom_firewall::pre'],
  }
  class {'::mcomaster::config::mcollective::server': 
    redis_host => "middleware"
  } 
  class {'::mcomaster::config::mcollective::client':
    redis_host => "middleware"
  }
  class {'::mcomaster': 
    redis_host => "middleware", 
    mcomaster_port => 8080, 
    admin_user     => "vagrant", 
    admin_email    => "vagrant@example.com", 
    admin_pass     => "vagrant123",  #should be at least 8 caracters. 
#    require        => Class['custom_firewall::pre'],
  }
}

node /mcserver/ {
  Yumrepo <| |> -> Package <| provider != 'rpm' |>
  include custom_firewall
  #include puppetlabs repo
  include puppetlabs
  #Configure hosts 
  include hosts_vagrant
  #config mcollective default plugins
  class {'mcollective_plugins':
    require => [ Class['puppetlabs'], Class['custom_firewall::pre'] ]
  }
  #Call custom class
  class { '::mcollective':
    middleware_hosts => [ 'middleware' ],
    require          => Class['custom_firewall::pre'],
  }
  class {'::mcomaster::config::mcollective::server': 
    redis_host => "middleware",
    require    => Class['custom_firewall::pre'],
  } 
}
