class custom_firewall::middleware($ports = [61613, 61614])  {
  firewall { '500 allow activemq ports':
    port   => $ports,
    proto  => tcp,
    action => accept,
  }
}
