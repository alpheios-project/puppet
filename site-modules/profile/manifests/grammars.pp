class profile::grammars {
  include profile::ssl
  include apache

   vcsrepo { '/var/www/grammar-bennett':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/grammar-bennett.git'
   }

   vcsrepo { '/var/www/grammar-smyth':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/grammar-smyth.git'
   }

   vcsrepo { '/var/www/grammar-allen-greenough':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/grammar-allen-greenough.git'
   }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'"
  ]

   apache::vhost { 'grammars.alpheios.net':
     port          => '80',
     docroot       => '/var/www/html',
     headers    => $headers,
     serveraliases => [ 'grammars.alpheios.org' ],
     aliases   => [
       { alias => '/bennett',
         path  => '/var/www/grammar-bennett',
       },
       { alias => '/smyth',
         path  => '/var/www/grammar-smyth',
       },
       { alias => '/allen-greenough',
         path  => '/var/www/grammar-allen-greenough',
       },
     ],
   }

   apache::vhost { 'ssl-grammars':
     port          => '443',
     docroot       => '/var/www/html',
     headers    => $headers,
     serveraliases => [ 'grammars.alpheios.org' ],
     aliases   => [
       { alias => '/bennett',
         path  => '/var/www/grammar-bennett',
       },
       { alias => '/smyth',
         path  => '/var/www/grammar-smyth',
       },
       { alias => '/allen-greenough',
         path  => '/var/www/grammar-allen-greenough',
       },
     ],
     ssl        => true,
     ssl_cert   => '/etc/ssl/certs/STAR_alpheios.net.crt',
     ssl_key    => '/etc/ssl/private/Alpheios.key',
     ssl_chain  => '/etc/ssl/certs/ca-bundle-client.crt',
   }

  firewall { '100 Allow ssl traffic for grammars':
    proto  => 'tcp',
    dport  => '443',
    action => 'accept',
  }
}
