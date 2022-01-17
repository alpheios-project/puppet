# ssl reverse proxy for blacklab
class profile::blacklab::apache {

  $proxy_pass = {
    'path'    => '/',
    'url'     => 'http://localhost:8888/corpus-frontend/',
  }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'",
      "set Cache-Control 'public max-age=2592000'"
  ]

  apache::vhost { 'blacklab-ssl':
    port                => '443',
    servername          => 'blacklab.alpheios.net',
    docroot             => '/var/www/html',
    proxy_preserve_host => 'On',
    proxy_pass          => [ $proxy_pass ],
    headers             => $headers,
    ssl        => true,
    ssl_cert   => '/etc/ssl/certs/STAR_alpheios.net.crt',
    ssl_key    => '/etc/ssl/private/Alpheios.key',
    ssl_chain  => '/etc/ssl/certs/ca-bundle-client.crt',
  }

  firewall { '200 Blacklab SSL Access':
    proto  => 'tcp',
    dport  => ['443'],
    action => 'accept',
  }
}
