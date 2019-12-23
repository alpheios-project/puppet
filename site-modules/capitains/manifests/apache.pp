# Webserver setup for Capitains
class capitains::apache {
  $servername = hiera('capitains::domain')

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

  apache::vhost { 'ssl-dts':
    apache_version => '2.5',
    servername     => $servername,
    port           => '443',
    docroot        => $capitains::www_root,
    proxy_pass     => [$proxy_pass],
    headers        => $headers,
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
