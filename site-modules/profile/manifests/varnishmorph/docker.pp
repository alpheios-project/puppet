class profile::varnishmorph::docker {
  include profile::docker::builder
  include profile::docker::runner
  include profile::ssl

  $docker_build_dir = lookup('docker_build_dir', String)
  $build_dir = "${docker_build_dir}/morphvarnish"


  file { $build_dir:
    ensure => directory,
  }

  file { "${build_dir}/default.vcl":
    content => epp('profile/varnishmorph/default.vcl.epp',{
      'backend1' => 'morph-a.alpheios.net',
      'backend2' => 'morph-b.alpheios.net',
      'ttl'      => '15552000', # set the default cache life to 6 months
    }),
    notify  => Exec['remove-docker-image'],
  }

  file { "${build_dir}/Dockerfile":
    content       => epp('profile/varnishmorph/Dockerfile.epp',{
      'cachesize' => '1G',
    }),
    notify  => Exec['remove-docker-image'],
  }

  exec { 'remove-docker-image':
      command     => "docker rmi -f morphvarnish",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image['morphvarnish'],
  }

  docker::image { 'morphvarnish':
    ensure     => present,
    docker_dir => $build_dir,
    notify     => Docker::Run['morphvarnish'],
    force      => true,
  }


  docker::run { 'morphvarnish':
    ensure  => present,
    image   => "morphvarnish:latest",
    ports   => [
      "8080:80",
    ],
  }

  firewall { '100 Varnish Access':
    proto  => 'tcp',
    dport  => ['8080'],
    action => 'accept',
  }
}
