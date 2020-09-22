# Build the Exist Docker image
class tools::build {
  $docker_build_dir = lookup('docker_build_dir', String)
  $exist_build_dir = "${docker_build_dir}/tools"
  $tokenizer_build_dir = "${docker_build_dir}/tokenizer"

  vcsrepo { "${exist_build_dir}":
      ensure   => latest,
      revision => 'master',
      provider => git,
      source   => 'https://github.com/alpheios-project/editors-docker.git',
      notify  => Exec['remove-exist-image'],
  }

  vcsrepo { "${tokenizer_build_dir}":
      ensure   => latest,
      revision => 'master',
      provider => git,
      source   => 'https://github.com/alpheios-project/tokenizer.git',
      notify  => Exec['remove-tokenizer-image'],
  }

  exec { 'remove-exist-image':
      command     => "docker rmi -f editors",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image['editors'],
  }

  exec { 'remove-tokenizer-image':
      command     => "docker rmi -f tokenizer",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image['tokenizer'],
  }

  docker::image { 'editors':
    ensure     => present,
    docker_dir => $exist_build_dir,
    notify     => Docker::Run['editors'],
    force      => true,
  }

  docker::image { 'tokenizer':
    ensure     => present,
    docker_dir => $tokenizer_build_dir,
    notify     => Docker::Run['tokenizer'],
    force      => true,
  }
}
