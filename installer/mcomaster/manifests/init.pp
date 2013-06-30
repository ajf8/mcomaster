class mcomaster ($redis_host='192.168.122.1', $redis_port='6379', $mcomaster_port='3000', $admin_user, $admin_pass, $admin_email) {
  file { '/etc/sysconfig/mcomaster':
    owner    => 'root',
    group    => 'mcomaster',
    mode     => '0640',
    content  => template('mcomaster/sysconfig'),
    require  => Package['mcomaster'],
  }

  yumrepo { 'ruby_scl':
    descr    => 'Ruby SCL',
    baseurl  => 'http://people.redhat.com/bkabrda/ruby193-rhel-6/',
    enabled  => 1,
    gpgcheck => 0,
  }

  file { '/etc/mcomaster/application.yml':
    content => template('mcomaster/application.yml'),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['mcomaster']
  }

  yumrepo { 'mcomaster':
    descr    => 'mcomaster',
    baseurl  => 'http://yum.mcomaster.org/snapshots/el6/$basearch',
    enabled  => 1,
    gpgcheck => 0,
  }

  exec { 'clear_mcomaster_yum':
    command => '/usr/bin/yum --disablerepo=\'*\' --enablerepo=mcomaster clean all',
    require => Yumrepo['mcomaster']
  }

  package { 'mcomaster':
    ensure  => 'latest',
    require => [ Yumrepo['mcomaster'], Exec['clear_mcomaster_yum'] ],
  }

  exec { 'create_mcomaster_db':
    command     => '/usr/bin/scl enable ruby193 "bin/rake db:reset"',
    environment => 'RAILS_ENV=production',
    cwd         => '/usr/share/mcomaster',
    user        => 'mcomaster',
    group       => 'mcomaster',
    creates     => '/usr/share/mcomaster/db/production.sqlite3',
    require     => Package['mcomaster'],
  }

  if ($admin_user and $admin_pass and $admin_email) {
    mcomaster::adduser { $admin_user:
      email    => $admin_email,
      password => $admin_pass,
    }
  }
}
