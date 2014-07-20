class mcomaster::config::mcollective::server($redis_port = 6379, $redis_host = 'localhost') {  
  include mcomaster::config::mcollective::redis_gem
  file { '/usr/libexec/mcollective/mcollective/registration/meta.rb':
    source => 'puppet:///modules/mcomaster/meta.rb',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    require => Package['mcollective'],
  } 
  file { '/usr/libexec/mcollective/mcollective/agent/registration.rb':
    source => 'puppet:///modules/mcomaster/registration.rb',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    require => Package['mcollective'],
  } 
  mcollective::server::setting { 'plugin.redis.host': value => $redis_host }
  mcollective::server::setting { 'plugin.redis.port': value => $redis_port }
  mcollective::server::setting { 'plugin.redis.db': value => 0}
  mcollective::server::setting { 'registerinterval': value => 300 }
  mcollective::server::setting { 'registration': value =>  "Meta" }
  mcollective::server::setting { 'direct_addressing': value => "yes"}
}
