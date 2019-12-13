class profile::www {
  include profile::ssl

  class { 'apache': }

   file { '/root/.ssh/id_rsa':
     ensure => present,
     owner   => "root",
     group   => "root",
     mode    => '0600',
     content => lookup('github_private_key',String),
     notify => Service["ssh"],
   }

   file {"/var/www/safari":
     ensure => directory,
   }

   file { "/var/www/safari/index.html":
      ensure  => file,
      content => epp('profile/www/index.html.epp', {
      }),
   }


  ssh_authorized_key { 'admin@alpheios.net':
    ensure => present,
    user   => 'root',
    type   => 'ssh-rsa',
    target => '/root/.ssh/id_rsa.pub',
    key    => lookup('github_public_key',String),
  }

  sshkey { 'github.com':
    ensure => present,
    type   => 'ssh-rsa',
    target => '/root/.ssh/known_hosts',
    key    => lookup('github_host_key',String),
  }

   vcsrepo { '/var/www/landing-page':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'git@github.com:alpheios-project/landing-page.git'
   }

   vcsrepo { '/var/www/demos':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/demos.git'
   }

   vcsrepo { '/var/www/enhanced-texts-v1':
     ensure   => latest,
     revision => 'v3.0.0.0',
     provider => git,
     source   => 'https://github.com/alpheios-project/enhanced-texts-v1.git'
   }

   vcsrepo { '/var/www/Gardener':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/Gardener.git'
   }

   vcsrepo { '/var/www/demo-paideia':
     ensure   => latest,
     revision => 'paideia',
     provider => git,
     source   => 'https://github.com/alpheios-project/embed-lib.git'
   }

   apache::vhost { 'www.alpheios.net':
     port          => '80',
     serveraliases => [ 'alpheios.net','www.alpheios.org','alpheios.org'],
     docroot       => '/var/www/landing-page/build',
     proxy_pass    =>   [ 
       { 'path'    =>  '/perl/latin', 'url' => 'http://morph.alpheios.net/legacy/latin' },
       { 'path'    =>  '/perl/greek', 'url' => 'http://morph.alpheios.net/legacy/greek' },
       { 'path'    =>  '/perl/aramorph2', 'url' => 'http://morph.alpheios.net/legacy/aramorph2' },
     ],
     aliases   => [
       { alias => '/alpheios-demos',
         path  => '/var/www/demos',
       },
       { alias => '/alpheios-texts',
         path  => '/var/www/enhanced-texts-v1',
       },
       { alias => '/alpheios-treebanks',
         path  => '/var/www/Gardener/docs',
       },
       { alias => '/demo-paideia',
         path  => '/var/www/demo-paideia',
       },
     ],
     allow_encoded_slashes => 'on',
   }

   apache::vhost { 'ssl-alpheios':
     port               => '443',
     serveraliases => [ 'www.alpheios.net','alpheios.net','alpheios.org','www.alpheios.org'], 
     docroot       => '/var/www/landing-page/build',
     proxy_pass    =>   [ 
       { 'path'    =>  '/perl/latin', 'url' => 'http://morph.alpheios.net/legacy/latin' },
       { 'path'    =>  '/perl/greek', 'url' => 'http://morph.alpheios.net/legacy/greek' },
       { 'path'    =>  '/perl/aramorph2', 'url' => 'http://morph.alpheios.net/legacy/aramorph2' },
     ],
     aliases   => [
       { alias => '/alpheios-demos',
         path  => '/var/www/demos',
       },
       { alias => '/alpheios-texts',
         path  => '/var/www/enhanced-texts-v1',
       },
       { alias => '/alpheios-treebanks',
         path  => '/var/www/Gardener/docs',
       },
       { alias => "/${hiera('safari_page')}",
         path  => '/var/www/safari',
       },
     ],
     allow_encoded_slashes => 'on',
     ssl        => true,
     ssl_cert   => '/etc/ssl/certs/STAR_alpheios.net.crt',
     ssl_key    => '/etc/ssl/private/Alpheios.key',
     ssl_chain  => '/etc/ssl/certs/ca-bundle-client.crt',
   }

   apache::vhost { 'ssl-alpheios-sf':
     port       => '443',
     servername => "${hiera('safari_domain')}.alpheios.net",
     docroot    => "/var/www/safari",
     allow_encoded_slashes => 'on',
     ssl        => true,
     ssl_cert   => '/etc/ssl/certs/STAR_alpheios.net.crt',
     ssl_key    => '/etc/ssl/private/Alpheios.key',
     ssl_chain  => '/etc/ssl/certs/ca-bundle-client.crt',
   }

  firewall { '100 Web Service Access':
    proto  => 'tcp',
    dport  => ['80','443'],
    action => 'accept',
  }
}
