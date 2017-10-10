class profile::morphology::wordsxml {

  ensure_packages(hiera('wordsxml::deps'))
  $base_dir = '/usr/local/wordsxml'
  
  vcsrepo { $base_dir:
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://github.com/alpheios-project/wordsxml',
  }
}

