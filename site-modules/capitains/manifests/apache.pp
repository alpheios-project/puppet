# Webserver setup for Capitains
class capitains::apache {

  $proxy_pass = {
    'path'    => '/',
    'url' => 'http://localhost:5000/',
  }

  $headers = [
   "set Access-Control-Allow-Origin '*'",
   "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'"
  ]

  apache::vhost { 'dts':
    servername  => hiera('capitains::domain'),
    port        => '80',
    docroot     => $capitains::www_root,
    proxy_pass  => [$proxy_pass],
    headers     => $headers,
  }

  firewall { '100 Allow web traffic for Capitains':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }
}
