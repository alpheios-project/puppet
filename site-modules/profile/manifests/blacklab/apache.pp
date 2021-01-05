# ssl reverse proxy for blacklab
class profile::blacklab::apache {
  include profile::ssl

  class {'apache':
    log_formats   => { combined => '%h %l %u %t \"%r\" %>s %b \"%{Content-Type}i\" \"%{Accepts}i\" \"%{Referer}i\" \"%{User-Agent}i\" %D'},
    default_vhost => false,
  }

  $proxy_pass = {
    'path'    => '/',
    'url'     => 'http://localhost:8888/',
  }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'",
      "set Cache-Control 'public max-age=2592000'"
  ]

  apache::vhost { 'blacklab':
    port                => '80',
    servername          => 'blacklab.alpheios.net',
    docroot             => '/var/www/html',
    suphp_engine        => 'off',
    redirect_status     => 'permanent',
    redirect_dest       => "https://blacklab.alpheios.net/"
  }

  apache::vhost { 'blacklab-ssl':
    port                => '443',
    servername          => 'blacklab.alpheios.net',
    docroot             => '/var/www/html',
    suphp_engine        => 'off',
    proxy_preserve_host => 'On',
    proxy_pass          => [ $proxy_pass ],
    headers             => $headers,
    ssl                 => true,
    ssl_cert            => '/etc/ssl/certs/STAR_alpheios.net.crt',
    ssl_key             => '/etc/ssl/private/Alpheios.key',
    ssl_chain           => '/etc/ssl/certs/ca-bundle-client.crt',
  }

  firewall { '200 Blacklab SSL Access':
    proto  => 'tcp',
    dport  => ['80','443'],
    action => 'accept',
  }
}
