class profile::ssl {

  file { '/etc/ssl/certs/ca-bundle-client.crt':
    content => lookup('ssl_chain'),
  }

  file { '/etc/ssl/certs/STAR_alpheios.net.crt':
    content => lookup('ssl_cert'),
  }

  file { '/etc/ssl/private/Alpheios.key':
    content  => lookup('ssl_key'),
    mode => '0640',
  }
}
