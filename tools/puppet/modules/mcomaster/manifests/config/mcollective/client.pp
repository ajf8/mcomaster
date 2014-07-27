class mcomaster::config::mcollective::client ($redis_host = localhost, $redis_port = 6379) {
  include mcomaster::config::mcollective::redis_gem
  file { '/usr/libexec/mcollective/mcollective/discovery/redisdiscovery.rb':
    source  => 'puppet:///modules/mcomaster/redisdiscovery.rb',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['mcollective'],
  } 

  file { '/usr/libexec/mcollective/mcollective/discovery/redisdiscovery.ddl':
    source => 'puppet:///modules/mcomaster/redisdiscovery.ddl',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    require => Package['mcollective'],
  } 
   mcollective::client::setting { 'plugin.redis.host': value => $redis_host }
   mcollective::client::setting { 'plugin.redis.port': value => $redis_port }
   mcollective::client::setting { 'plugin.redis.db': value => 0}
   mcollective::client::setting { 'registerinterval': value => 300 }
   mcollective::client::setting { 'registration': value =>  "Meta" }
   mcollective::client::setting { 'direct_addressing': value => "yes"}
   mcollective::client::setting { 'default_discovery_method': value => "redisdiscovery"}
}

