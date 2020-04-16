# ssl reverse proxy for varnish plus serve lexdata
class profile::varnishlex::apache {

  class {'apache':
    log_formats   => { combined => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D'},
    default_vhost => false,
    file_e_tag    => 'all',
  }

  $proxy_pass = {
    'path'    => '/exist/',
    'url'     => 'http://localhost:80/exist/',
  }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'",
      "set Cache-Control 'public max-age=2592000'"
  ]

  apache::vhost { 'lexdata':
    port                => '8088',
    servername          => 'lexdata.alpheios.net',
    docroot             => '/var/www/html',
    proxy_preserve_host => 'On',
    proxy_pass          => [ $proxy_pass ],
    headers             => $headers,
    aliases   => [
      { alias => '/lexdata',
        path  => '/usr/local/lexdata',
      }
    ],
  }
  apache::vhost { 'repos1-ssl':
    port                => '443',
    servername          => 'repos-v.alpheios.net',
    serveraliases       => [ 'repos1.alpheios.net'],
    docroot             => '/var/www/html',
    proxy_preserve_host => 'On',
    proxy_pass          => [ $proxy_pass ],
    headers             => $headers,
    aliases   => [
      { alias => '/lexdata',
        path  => '/usr/local/lexdata',
      }
    ],
    ssl        => true,
    ssl_cert   => '/etc/ssl/certs/STAR_alpheios.net.crt',
    ssl_key    => '/etc/ssl/private/Alpheios.key',
    ssl_chain  => '/etc/ssl/certs/ca-bundle-client.crt',
  }

  firewall { '101 SSL Access':
    proto  => 'tcp',
    dport  => ['8088','443'],
    action => 'accept',
  }
}
