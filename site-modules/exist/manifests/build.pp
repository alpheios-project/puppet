# Build the Exist Docker image
class exist::build {
  $docker_build_dir = lookup('docker_build_dir', String)
  $exist_build_dir = "${docker_build_dir}/exist"

  vcsrepo { "${exist_build_dir}":
      ensure   => latest,
      revision => 'master',
      provider => git,
      source   => 'https://github.com/alpheios-project/lex-docker',
      notify  => Exec['remove-exist-image'],
  }

  exec { 'remove-exist-image':
      command     => "docker rmi -f lexsvc",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image['lexsvc'],
  }

  docker::image { 'lexsvc':
    ensure     => present,
    docker_dir => $exist_build_dir,
    notify     => Docker::Run['lexsvc'],
  }
}
