class profile::www {

  class { 'apache': }

   vcsrepo { '/var/www/landing-page':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/landing-page.git'
   }

   vcsrepo { '/var/www/demos':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/demos.git'
   }

   vcsrepo { '/var/www/enhanced-texts-v1':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/enhanced-texts-v1.git'
   }

   apache::vhost { 'www.alpheios.net':
     port          => '80',
     serveraliases => [ 'alpheios.net','www.melampus.org','melampus.org'],
     docroot       => '/var/www/landing-page/build',
     proxy_pass    =>   [ 
       { 'path'    => '/content', 'url' => 'http://archive.alpheios.net/content'},
       { 'path'    => '/sites', 'url' => 'http://archive.alpheios.net/sites'},
       { 'path'    =>  '/poetry', 'url' => 'http://archive.alpheios.net/poetry'},
       { 'path'    =>  '/perl/latin', 'url' => 'http://morph.alpheios.net/legacy/latin' },
       { 'path'    =>  '/perl/greek', 'url' => 'http://morph.alpheios.net/legacy/greek' },
       { 'path'    =>  '/perl/aramorph2', 'url' => 'http://morph.alpheios.net/legacy/aramorph2' },
       { 'path'    =>  '/xpi-install', 'url' => 'http://archive.alpheios.net/xpi-install' },
       { 'path'    =>  '/xpi-updates', 'url' => 'http://archive.alpheios.net/xpi-updates' },
     ],
     aliases   => [
       { alias => '/alpheios-demos',
         path  => '/var/www/demos',
       },
       { alias => '/alpheios-texts',
         path  => '/var/www/enhanced-texts-v1',
       }
     ]
   }
}
