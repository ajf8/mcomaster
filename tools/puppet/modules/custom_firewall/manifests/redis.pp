class custom_firewall::redis ($redis_ports = [6379]) {
  firewall { '500 allow redis ports':
    port   => $redis_port,
    proto  => tcp,
    action => accept,
  }

}
