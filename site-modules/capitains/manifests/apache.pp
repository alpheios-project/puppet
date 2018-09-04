# Webserver setup for Capitains
class capitains::apache {

  $proxy_pass_dts_base = {
    'path'    => '/api/dts',
    'url' => 'http://dts.alpheios.net/dts',
  }

  $proxy_pass_dts = {
    'path'    => '/api/dts/',
    'url' => 'http://dts.alpheios.net/dts/',
  }

  $proxy_pass = {
    'path'    => '/',
    'url' => 'http://localhost:5000/',
  }

  $headers = [
   "set Access-Control-Allow-Origin '*'",
   "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'"
  ]

  apache::vhost { 'texts':
    servername  => hiera('capitains::domain'),
    port        => '80',
    docroot     => $capitains::www_root,
    proxy_pass  => [$proxy_pass_dts_base, $proxy_pass_dts, $proxy_pass],
    headers     => $headers,
  }

  firewall { '100 Allow web traffic for Capitains':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }
}
