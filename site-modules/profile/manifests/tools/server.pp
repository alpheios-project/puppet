# Run the Handle Server container
class profile::tools::server {
  include apache
  include profile::ssl
  include profile::docker::runner
  include tools::server

  $proxy_pass = {
    'path'    => '/exist/',
    'url'     => 'http://localhost:8080/exist/',
  }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'"
  ]

  apache::vhost { 'tools.alpheios.net':
    port          => '80',
    docroot       => '/var/www/html',
    proxy_pass => [ $proxy_pass ],
    headers    => $headers,

  }

  apache::vhost { 'ssl-tools.alpheios.net':
     port          => '443',
     docroot       => '/var/www/html',
     proxy_pass => [ $proxy_pass ],
     headers    => $headers,
     ssl        => true,
     ssl_cert   => '/etc/ssl/certs/STAR_alpheios.net.crt',
     ssl_key    => '/etc/ssl/private/Alpheios.key',
     ssl_chain  => '/etc/ssl/certs/ca-bundle-client.crt',
   }

}
