class profile::morphology::morpheus {

  $base_dir = '/usr/local/morpheus'
  
  vcsrepo { $base_dir:
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://github.com/alpheios-project/morpheus',
  }
}

