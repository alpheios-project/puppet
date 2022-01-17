# Run the Handle Server container
class profile::tools::server {
  include profile::ssl
  include profile::docker::runner
  include tools::server

  class {'apache':
    log_formats   => { combined => '%h %l %u %t \"%r\" %>s %b \"%{Content-Type}i\" \"%{Accepts}i\" \"%{Referer}i\" \"%{User-Agent}i\" %D'},
    default_vhost => false,
  }

  $proxy_pass = {
    'path'    => '/exist/',
    'url'     => 'http://localhost:8080/exist/',
  }

  $proxy_pass_tokenizer = {
    'path'    => '/tokenizer/',
    'url'     => 'http://localhost:5000/',
  }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'",
      "set Access-Control-Allow-Headers '*'"
  ]

  apache::vhost { 'tools.alpheios.net':
    port          => '80',
    docroot       => '/var/www/html',
    proxy_pass => [ $proxy_pass, $proxy_pass_tokenizer ],
    headers    => $headers,

  }

  apache::vhost { 'ssl-tools.alpheios.net':
     port          => '443',
     docroot       => '/var/www/html',
     proxy_pass => [ $proxy_pass, $proxy_pass_tokenizer ],
     headers    => $headers,
     ssl        => true,
     ssl_cert   => '/etc/ssl/certs/STAR_alpheios.net.crt',
     ssl_key    => '/etc/ssl/private/Alpheios.key',
     ssl_chain  => '/etc/ssl/certs/ca-bundle-client.crt',
   }

}
