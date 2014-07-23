class custom_firewall::redis ($ports = [6379]) {
  firewall { '500 allow redis ports':
    port   => $ports,
    proto  => tcp,
    action => accept,
  }

}
