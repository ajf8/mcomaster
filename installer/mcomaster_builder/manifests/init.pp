class mcomaster_builder {
  package { 'rpm-build':
    ensure => 'present',
  }

  package { 'ruby193-ruby':
    ensure => 'present',
  }

  package { 'ruby193-rubygems':
    ensure => 'present',
  }

  package { 'ruby193-rubygem-bundler':
    ensure => 'present',
  }

  package { 'ruby193-ruby-devel':
    ensure => 'present',
  }

  package { 'make':
    ensure => 'present',
  }

  package { 'gcc':
    ensure => 'present',
  }

  package { 'gcc-c++':
    ensure => 'present',
  }

  package { 'sqlite-devel':
    ensure => 'present',
  }
}
