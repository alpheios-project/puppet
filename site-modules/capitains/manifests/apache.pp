# Webserver setup for Capitains
class capitains::apache {

  $proxy_pass_dts_base = {
    'path'    => '/api/dts',
    'url' => 'http://dts.alpheios.net/api/dts',
  }

  $proxy_pass_dts = {
    'path'    => '/api/dts/',
    'url' => 'http://dts.alpheios.net/api/dts/',
  }

  $proxy_pass = {
    'path'    => '/',
    'url' => 'http://localhost:5000/',
  }

  $proxy_pass_not = {
    'path' => '/assets',
    'url'  => '!',
  }

  $headers = [
   "set Access-Control-Allow-Origin '*'",
   "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'"
  ]

  apache::vhost { 'texts':
    servername => hiera('capitains::domain'),
    port       => '80',
    docroot    => $capitains::www_root,
    proxy_pass => [$proxy_pass_not, $proxy_pass_dts_base, $proxy_pass_dts, $proxy_pass],
    headers    => $headers,
    aliases    => [
      {
        alias    => '/assets/nemo.secondary/static',
        path     => "${capitains::app_root}/alpheios_nemo_ui/data/assets/images",
      },
      {
        alias    => '/assets/nemo.secondary',
        path     => "${capitains::app_root}/alpheios_nemo_ui/data/assets",
      },
    ],
  }

  firewall { '100 Allow web traffic for Capitains':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }
}
