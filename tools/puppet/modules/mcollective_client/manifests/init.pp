class mcollective_client($redis_host='192.168.122.1',
                         $redis_port='6379',
                         $stomp_host='192.168.122.1',
                         $stomp_port='61613',
                         $stomp_user='mcollective',
                         $stomp_pass='password'
) {
  package { 'mcollective-client':
    ensure  => '2.5.3-1.el6',
    require => Class['puppetlabs'],
  }

  file { '/usr/libexec/mcollective/mcollective/discovery/redisdiscovery.rb':
    source  => 'puppet:///modules/mcollective_client/redisdiscovery.rb',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['mcollective'],
  } 

  file { '/usr/libexec/mcollective/mcollective/discovery/redisdiscovery.ddl':
    source => 'puppet:///modules/mcollective_client/redisdiscovery.ddl',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    require => Package['mcollective'],
  } 

  file { '/etc/mcollective/client.cfg':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mcollective_client/client.cfg'),
    notify  => Service['mcollective'],
    require => Package['mcollective-client'],
  }

  exec { 'client_add_redis_gem':
    command => '/usr/bin/gem install redis',
    unless  => '/usr/bin/gem list --local | /bin/grep -q redis',
  }
}
