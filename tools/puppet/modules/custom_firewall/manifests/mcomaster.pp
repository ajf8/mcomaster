class custom_firewall::mcomaster($ports = [8080])  {
  firewall { '500 allow mcomaster ports':
    port   => $ports,
    proto  => tcp,
    action => accept,
  }
}
