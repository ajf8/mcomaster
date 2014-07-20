class mcomaster::config::mcollective::redis_gem($version = "latest") {
  if ! defined_with_params(Package['redis'], {'provider' => 'gem' }) { 
     package{'redis':
       provider => gem,
       ensure   => $version,
       notify   => Service['mcollective']
     }
  }
}
