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


node /middleware/ {
  #config package repository
  include puppetlabs
  #config /etc/hosts
  include hosts_vagrant
  #Config firewall rules
  include custom_firewall
  include custom_firewall::middleware
  include custom_firewall::redis
  #config redis
  class { '::redis': 
    version => '2.8.13', 
    redis_max_memory => '100mb'
  }
  #config mcollective
  class { '::mcollective':
    middleware       => true,
    middleware_hosts => [ 'middleware' ],
  }
  class {'::mcomaster::config::mcollective::server': 
    redis_host => "middleware"
  } 

}
node /mcomaster/ {
  #config package repository
  include puppetlabs
  #config /etc/hosts
  include hosts_vagrant
  class { '::mcollective':
    client            => true,
    middleware_hosts => [ 'middleware' ],
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
    admin_pass     => "vagrant"
  }
}

node /mcserver/ {
notify {'mcserver':}
  include custom_firewall
  #include puppetlabs repo
  include puppetlabs
  #Configure hosts 
  include hosts_vagrant
  #Call custom class
  class { '::mcollective':
    middleware_hosts => [ 'middleware' ],
  }
  class {'::mcomaster::config::mcollective::server': 
    redis_host => "middleware"
  } 
  class {'::mcomaster::config::mcollective::client':
    redis_host => "middleware"
  }
}
