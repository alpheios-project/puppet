# Webserver setup for Capitains
class capitains::apache {
  $servername = hiera('capitains::domain')

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

  $proxy_pass_not_assets = {
    'path' => '/assets',
    'url'  => '!',
  }

  $proxy_pass_not_images = {
    'path' => '/images',
    'url'  => '!',
  }

  $headers = [
   "set Access-Control-Allow-Origin '*'",
   "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'"
  ]

  apache::vhost { 'texts':
    servername      => $servername,
    serveraliases => [ 'texts-beta.alpheios.net','texts.alpheios.org','texts-test.alpheios.net','texts-test.alpheios.org'],
    port            => '80',
    docroot         => $capitains::www_root,
    redirect_status => 'permanent',
    redirect_dest   => "https://${servername}/"
  }

  apache::vhost { 'ssl-texts':
    apache_version => '2.5',
    servername     => $servername,
    serveraliases => [ 'texts-beta.alpheios.net','texts.alpheios.org','texts-test.alpheios.net','texts-test.alpheios.org'],
    protocols      => ['h2', 'h2c', 'http/1.1'],
    port           => '443',
    docroot        => $capitains::www_root,
    proxy_pass     => [$proxy_pass_not_assets, $proxy_pass_not_images, $proxy_pass_dts_base, $proxy_pass_dts, $proxy_pass],
    headers        => $headers,
    aliases    => [
      {
        alias    => '/images',
        path     => "${capitains::app_root}/alpheios_nemo_ui/data/assets/images",
      },
      {
        alias    => '/assets/nemo.secondary/static',
        path     => "${capitains::app_root}/alpheios_nemo_ui/data/assets/images",
      },
      {
        alias    => '/assets/nemo.secondary/js/alpheios-embedded.min.js',
        path     => "${capitains::app_root}/alpheios_nemo_ui/data/assets/node_modules/alpheios-embedded/dist/alpheios-embedded.min.js",
      },
      {
        alias    => '/assets/nemo.secondary/js/alpheios-components.min.js',
        path     => "${capitains::app_root}/alpheios_nemo_ui/data/assets/node_modules/alpheios-components/dist/alpheios-components.min.js",
      },
      {
        alias    => '/assets/nemo.secondary/css/style-components.min.css',
        path     => "${capitains::app_root}/alpheios_nemo_ui/data/assets/node_modules/alpheios-components/dist/style/style-components.min.css",
      },
      {
        alias    => '/assets/nemo.secondary',
        path     => "${capitains::app_root}/alpheios_nemo_ui/data/assets",
      },
    ],
    ssl             => true,
    ssl_cert        => '/etc/ssl/certs/STAR_alpheios.net.crt',
    ssl_key         => '/etc/ssl/private/Alpheios.key',
    ssl_chain       => '/etc/ssl/certs/ca-bundle-client.crt',
    ssl_cipher      => 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4',
    custom_fragment => 'DeflateBufferSize 16192', # needed to avoid transfer-encoding chunked for alpheios-embedded.js
  }

  firewall { '100 Allow web traffic for Capitains':
    proto  => 'tcp',
    dport  => ['80','443'],
    action => 'accept',
  }
}
