# Run the Handle Server container
class profile::exist::server {
  include apache
  include profile::docker::runner
  include exist::server
  include profile::ssl

  $proxy_pass = {
    'path'    => '/exist/',
    'url'     => 'http://localhost:8080/exist/',
  }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'"
  ]

  apache::vhost { 'repos1.alpheios.net':
    port          => '80',
    docroot       => '/var/www/html',
    proxy_pass => [ $proxy_pass ],
    rewrites   => [ 
      {'rewrite_rule' => [ '/exist/rest/db/xq/alpheios-text.xq http://repos-archive.alpheios.net/exist/rest/db/xq/alpheios-text.xq']},
      {'rewrite_rule' => [ '/exist/rest/db/xq/alpheios-get-ref.xq http://repos-archive.alpheios.net/exist/rest/db/xq/alpheios-get-ref.xq']},
      {'rewrite_rule' => [ '/exist/rest/db/xq/alpheios-get-toc.xq http://repos-archive.alpheios.net/exist/rest/db/xq/alpheios-get-toc.xq']},
      {'rewrite_rule' => [ '/exist/rest/db/app/(.*)$ http://tools.alpheios.net/exist/rest/db/app/$1']},
    ],
    headers    => $headers,

  }
  
  apache::vhost { 'repos1-ssl':
    port              => '443',
    servername        => 'repos1.alpheios.net',
    docroot           => '/var/www/html',
    proxy_pass        => [ $proxy_pass ],
    rewrites          => [ 
      {'rewrite_rule' => [ '/exist/rest/db/xq/alpheios-text.xq http://repos-archive.alpheios.net/exist/rest/db/xq/alpheios-text.xq']},
      {'rewrite_rule' => [ '/exist/rest/db/xq/alpheios-get-ref.xq http://repos-archive.alpheios.net/exist/rest/db/xq/alpheios-get-ref.xq']},
      {'rewrite_rule' => [ '/exist/rest/db/xq/alpheios-get-toc.xq http://repos-archive.alpheios.net/exist/rest/db/xq/alpheios-get-toc.xq']},
      {'rewrite_rule' => [ '/exist/rest/db/app/(.*)$ http://tools.alpheios.net/exist/rest/db/app/$1']},
    ],
    headers    => $headers,
    ssl        => true,
    ssl_cert   => '/etc/ssl/certs/STAR_alpheios.net.crt',
    ssl_key    => '/etc/ssl/private/Alpheios.key',
    ssl_chain  => '/etc/ssl/certs/ca-bundle-client.crt',

  }

}
