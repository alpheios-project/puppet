class profile::blacklab::docker {
  include 'docker'

  $docker_build_dir = lookup('docker_build_dir', String)
  $build_dir = "${docker_build_dir}/blacklab"


  vcsrepo { "${build_dir}":
      ensure   => latest,
      revision => 'master',
      provider => git,
      source   => 'https://github.com/alpheios-project/blacklab-docker.git',
      notify  => File["$build_dir/Dockerfile"],
  }


  file { "${build_dir}/Dockerfile":
    content       => epp('profile/blacklab/Dockerfile.epp',{
      'corpus_release' => '0.0.1',
    }),
    notify  => Exec['remove-blacklab-image'],
  }

  exec { 'remove-blacklab-image':
      command     => "docker rmi -f alpheios-blacklab",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image['alpheios-blacklab'],
  }

  docker::image { 'alpheios-blacklab':
    ensure     => present,
    docker_dir => $build_dir,
    notify     => Docker::Run['alpheios-blacklab'],
    force      => true,
  }


  docker::run { 'alpheios-blacklab':
    ensure  => present,
    image   => "blacklab:latest",
    restart => 'always',
    ports   => [
      "8888:8080",
    ],
  }

  firewall { '300 Blacklab Access':
    proto  => 'tcp',
    dport  => ['8888'],
    action => 'accept',
  }
}
