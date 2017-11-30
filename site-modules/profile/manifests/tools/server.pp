# Run the Handle Server container
class profile::tools::server {
  include apache
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

}
