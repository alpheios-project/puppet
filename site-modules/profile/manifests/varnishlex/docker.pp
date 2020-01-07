class profile::varnishlex::docker {
  include profile::docker::builder
  include profile::docker::runner
  include profile::ssl

  $docker_build_dir = lookup('docker_build_dir', String)
  $build_dir = "${docker_build_dir}/lexvarnish"


  file { $build_dir:
    ensure => directory,
  }

  file { "${build_dir}/default.vcl":
    content => epp('profile/varnishlex/default.vcl.epp',{
      'backend1' => 'repos-a.alpheios.net',
      'backend2' => 'repos-b.alpheios.net',
      'ttl'      => '15552000', # set the default cache life to 6 months
    }),
    notify  => Exec['remove-docker-image'],
  }

  file { "${build_dir}/Dockerfile":
    content       => epp('profile/varnishlex/Dockerfile.epp',{
      'cachesize' => '1G',
    }),
    notify  => Exec['remove-docker-image'],
  }

  exec { 'remove-docker-image':
      command     => "docker rmi -f lexvarnish",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image['lexvarnish'],
  }

  docker::image { 'lexvarnish':
    ensure     => present,
    docker_dir => $build_dir,
    notify     => Docker::Run['lexvarnish'],
    force      => true,
  }


  docker::run { 'lexvarnish':
    ensure  => present,
    image   => "lexvarnish:latest",
    ports   => [
      "80:80",
    ],
  }

  firewall { '100 Varnish Access':
    proto  => 'tcp',
    dport  => ['80'],
    action => 'accept',
  }
}
