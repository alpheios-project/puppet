# Run the Handle Server container
class profile::tools::server {
  include profile::docker::runner
  include tools::server

  class {'apache':
    log_formats   => { combined => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D'},
    default_vhost => false,
  }

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
