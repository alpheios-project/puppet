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
     serveraliases => [ 'melampus.org'],
     docroot       => '/var/www/landing-page/build',
   }
                                                                                     
}
