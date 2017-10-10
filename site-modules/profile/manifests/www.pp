class profile::www {

  class { 'apache': }

   vcsrepo { '/var/www/landing-page':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/landing-page.git'
   }

   apache::vhost { 'www.melampus.org':
     port          => '80',
     serveraliases => [ 'melampus.org','dev.alpheios.net'],
     docroot       => '/var/www/landing-page/build',
     proxy_pass    =>   [ 
       { 'path'    => '/content', 'url' => 'http://archive.alpheios.net/content'},
       { 'path'    => '/sites', 'url' => 'http://archive.alpheios.net/sites'},
       { 'path'    => '/alpheios-texts', 'url' => 'http://archive.alpheios.net/alpheios-texts' },
       { 'path'    => '/alpheios-demos', 'url' => 'http://archive.alpheios.net/alpheios-demos' },
       { 'path'    =>  '/poetry', 'url' => 'http://archive.alpheios.net/poetry'},
       { 'path'    =>  '/perl', 'url' => 'http://archive.alpheios.net/perl' },
       { 'path'    =>  '/xpi-install', 'url' => 'http://archive.alpheios.net/xpi-install' },
       { 'path'    =>  '/xpi-updates', 'url' => 'http://archive.alpheios.net/xpi-updates' },
     ],
   }
}
