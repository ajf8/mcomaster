class mcollective_shell_agent {
  file { '/usr/libexec/mcollective/mcollective/agent/shell':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/usr/libexec/mcollective/mcollective/agent/shell/job.rb':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/mcollective_shell_agent/shell/job.rb'
  }

  file { '/usr/libexec/mcollective/mcollective/agent/shell.rb':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/mcollective_shell_agent/shell.rb'
  }

  file { '/usr/libexec/mcollective/mcollective/agent/shell.ddl':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/mcollective_shell_agent/shell.ddl'
  }
}
