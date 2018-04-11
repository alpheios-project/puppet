# Build the Docker image
class pwa::build {
  $docker_build_dir = lookup('docker_build_dir', String)
  $pwa_user = 'balmas'
  $pwa_build_dir = "${docker_build_dir}/${pwa_user}/pwa"

  class { 'nvm':
    user         => $pwa_user,
    install_node => '8.7.0',
  }

  file {"${docker_build_dir}/$pwa_user":
    ensure => directory,
    owner  => $pwa_user,
    mode   => '0777',
  }


  file { '/usr/local/bin/build-pwa':
    source   => 'puppet:///modules/pwa/build-pwa.sh',
    mode => '0775',
  } 

  vcsrepo { "${pwa_build_dir}":
      ensure   => latest,
      user     => $pwa_user,
      revision => 'master',
      provider => git,
      source   => 'https://github.com/alpheios-project/pwa-prototype.git',
      notify   => Exec['build-pwa-source'],
  }

  file { "${pwa_build_dir}/docker-nginx-config/certs":
    ensure => directory,
    require => Vcsrepo[$pwa_build_dir],
  }

  file { "${pwa_build_dir}/docker-nginx-config/conf.d/default.conf":
    source => 'puppet:///modules/pwa/default.conf',
    owner  => $pwa_user,
  }

  file { "${pwa_build_dir}/docker-nginx-config/certs/ca-bundle-client.crt":
    content => lookup('ssl_chain'),
    require => File["${pwa_build_dir}/docker-nginx-config/certs"],
  }

  file { "${pwa_build_dir}/docker-nginx-config/certs/STAR_alpheios.net.crt":
    content => lookup('ssl_cert'),
    require => File["${pwa_build_dir}/docker-nginx-config/certs"],
  }

  file { "${pwa_build_dir}/docker-nginx-config/certs/Alpheios.key":
    content => lookup('ssl_key'),
    mode    => '0640',
    require => File["${pwa_build_dir}/docker-nginx-config/certs"],
  }

  exec { 'build-pwa-source':
    cwd         => $pwa_build_dir,
    user        => $pwa_user,
    environment => ["HOME=/home/${pwa_user}", "NVM_DIR=/home/${pwa_user}/.nvm"],
    command     => '/usr/local/bin/build-pwa',
    notify      => Exec['remove-pwa-image'],
    require     => Class['nvm'],
  }

  exec { 'remove-pwa-image':
      command     => "docker rmi -f pwa",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image['pwa'],
  }

  docker::image { 'pwa':
    ensure      => present,
    docker_file => "${pwa_build_dir}/docker-image/Dockerfile",
    notify      => Docker::Run['pwa'],
    force       => true,
  }
}
