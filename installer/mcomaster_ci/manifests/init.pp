class mcomaster_ci {
  group { 'jenkins':
    ensure => 'present',
  }

  user { 'jenkins':
    home   => '/home/jenkins',
    gid    => 'jenkins',
    ensure => 'present',
    shell  => '/bin/bash',
  }

  file { '/home/jenkins':
    ensure  => 'directory',
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0700',
    require => User['jenkins']
  }

  file { '/home/jenkins/.ssh':
    ensure => 'directory',
    mode   => '0700',
    owner  => 'jenkins',
    group  => 'jenkins',
  }

  package { 'java-1.7.0-openjdk':
    ensure => 'present',
  }
}
