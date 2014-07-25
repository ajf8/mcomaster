define mcomaster::adduser($email, $password, $env='production')
{
  exec { "add_user_${name}":
    command     => "/usr/bin/scl enable ruby193 \"/usr/share/mcomaster/script/add_user.sh -u ${name} -m ${email} -p ${password}\"",
    cwd         => '/usr/share/mcomaster',
    environment => "RAILS_ENV=${env}",
    user        => 'mcomaster',
    group       => 'mcomaster',
    require     => [ Exec['create_mcomaster_db'], Package['mcomaster'] ]
  }
}
