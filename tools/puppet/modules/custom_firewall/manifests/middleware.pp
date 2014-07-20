class custom_firewall::middleware($activemq_ports = [61613, 61614])  {
  firewall { '500 allow activemq ports':
    port   => $activemq_port,
    proto  => tcp,
    action => accept,
  }
}
