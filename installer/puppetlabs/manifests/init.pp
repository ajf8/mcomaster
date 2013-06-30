class puppetlabs {
  yumrepo { 'puppetlabs-products':
    baseurl  => 'http://yum.puppetlabs.com/el/6/products/$basearch',
    enabled  => 1,
    gpgcheck => 0
  }

  yumrepo { 'puppetlabs-deps':
    baseurl  => 'http://yum.puppetlabs.com/el/6/dependencies/$basearch',
    enabled  => 1,
    gpgcheck => 0
  }
}
