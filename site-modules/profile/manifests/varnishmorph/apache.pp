# ssl reverse proxy for varnish plus serve lexdata
class profile::varnishmorph::apache {

  class {'apache':
    log_formats   => { combined => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D'},
    default_vhost => false,
    file_e_tag    => 'all',
  }

  $proxy_pass = {
    'path'    => '/api/v1',
    'url'     => 'http://localhost:8080',
  }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'",
      "set Cache-Control 'public max-age=2592000'"
  ]

  apache::vhost { 'morph':
    port                => '80',
    servername          => 'morph-v.alpheios.net',
    serveraliases       => [ 'morph.alpheios.net'],
    docroot             => '/var/www/html',
    proxy_preserve_host => 'On',
    proxy_pass          => [ $proxy_pass ],
  }

  apache::vhost { 'morph-ssl':
    port                => '443',
    servername          => 'morph-v.alpheios.net',
    serveraliases       => [ 'morph.alpheios.net'],
    docroot             => '/var/www/html',
    proxy_preserve_host => 'On',
    proxy_pass          => [ $proxy_pass ],
    headers             => $headers,
    ssl        => true,
    ssl_cert   => '/etc/ssl/certs/STAR_alpheios.net.crt',
    ssl_key    => '/etc/ssl/private/Alpheios.key',
    ssl_chain  => '/etc/ssl/certs/ca-bundle-client.crt',
  }

  firewall { '101 HTTP AND SSL Access':
    proto  => 'tcp',
    dport  => ['80','443'],
    action => 'accept',
  }
}
