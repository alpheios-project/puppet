class profile::lexdata {

   file { '/usr/local/lexdata':
     ensure => directory,
   }

   vcsrepo { '/usr/local/lexdata/ls':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/ls.git'
   }

   vcsrepo { '/usr/local/lexdata/lsj':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/lsj.git'
   }

   vcsrepo { '/usr/local/lexdata/ml':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/ml.git'
   }

   vcsrepo { '/usr/local/lexdata/stg':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/stg.git'
   }

   vcsrepo { '/usr/local/lexdata/aut':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/aut.git'
   }

   vcsrepo { '/usr/local/lexdata/as':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/as.git'
   }

   vcsrepo { '/usr/local/lexdata/sal':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/sal.git'
   }

   vcsrepo { '/usr/local/lexdata/dod':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/dod.git'
   }

   vcsrepo { '/usr/local/lexdata/lan':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/lan.git'
   }

   vcsrepo { '/usr/local/lexdata/majorplus':
     ensure   => latest,
     revision => 'master',
     provider => git,
     source   => 'https://github.com/alpheios-project/majorplus.git'
   }

}
