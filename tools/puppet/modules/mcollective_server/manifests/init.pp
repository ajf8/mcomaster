class mcollective_server($redis_host='192.168.122.1',
                         $redis_port='6379',
                         $stomp_host='192.168.122.1',
                         $stomp_port='61613',
                         $stomp_user='mcollective',
                         $stomp_pass='password'
) {
  package { 'mcollective':
    ensure  => '2.5.3-1.el6',
    require => Class['puppetlabs'],
  }
  
  class { 'mcollective_server::facts':
    require => Package['mcollective']
  }

  file { '/usr/libexec/mcollective/mcollective/registration/meta.rb':
    source => 'puppet:///modules/mcollective_server/meta.rb',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    require => Package['mcollective'],
  } 

  file { '/usr/libexec/mcollective/mcollective/agent/registration.rb':
    source => 'puppet:///modules/mcollective_server/registration.rb',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    require => Package['mcollective'],
  } 

  service { 'mcollective':
    ensure  => 'running',
    enable  => true,
    require => [
                 File['/etc/mcollective/facts.yaml'],
                 Package['mcollective'],
                 File['/etc/mcollective/server.cfg'],
                 Exec['add_redis_gem'],
                 File['/usr/libexec/mcollective/mcollective/discovery/redisdiscovery.rb'],
                 File['/usr/libexec/mcollective/mcollective/discovery/redisdiscovery.ddl'],
                 File['/usr/libexec/mcollective/mcollective/registration/meta.rb'],
                 File['/usr/libexec/mcollective/mcollective/agent/registration.rb'],
               ],
  }

  file { '/etc/mcollective/server.cfg':
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('mcollective_server/server.cfg'),
    require => Package['mcollective-client'],
    notify  => Service['mcollective'],
  }

  exec { 'add_redis_gem':
    command => '/usr/bin/gem install redis',
    unless  => '/usr/bin/gem list --local | /bin/grep -q redis',
  }
}
