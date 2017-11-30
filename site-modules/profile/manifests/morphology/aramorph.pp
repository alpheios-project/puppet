class profile::morphology::aramorph {
  include profile::docker::builder
  $docker_build_dir = lookup('docker_build_dir', String)
  $build_dir = "${docker_build_dir}/aramorph"

  $password = lookup('bama2_repo_password', String)

  vcsrepo { $build_dir:
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://github.com/alpheios-project/morphwrappers',
  }

  file { "${build_dir}/Dockerfile":
    content                 => epp('profile/morphology/aramorph/Dockerfile.epp', {
      'bama2_repo_user'     => 'balmas@gmail.com',
      'bama2_repo_password' => $password,
    }),
    require => Vcsrepo[$app_root],
  }

  docker::image { 'aramorph':
    ensure    => 'present',
    image_tag => 'latest',
    docker_dir => $build_dir,
    notify     => Docker::Run['aramorph'],
  }

  docker::run { 'aramorph':
    ensure  => present,
    image   => "aramorph:latest",
    ports   => [
      "8088:80",
    ],
    require => Docker::Image['aramorph'],
  }

  firewall { '100 Allow web traffic for aramorph':
    proto  => 'tcp',
    dport  => 8088,
    action => 'accept',
  }

}

