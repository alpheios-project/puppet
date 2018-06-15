# Build the Docker image
class pwa::build ($mode = 'pwa', $branch = 'master') {
  $docker_build_dir = lookup('docker_build_dir', String)
  $pwa_user = 'balmas'
  $pwa_build_dir = "${docker_build_dir}/${pwa_user}/${mode}"
  $server_name = "${mode}.alpheios.net" 
  if ($mode == 'pwa') {
    $target = 'build-node-prod'
  } else {
    $target = 'build-node-dev'
  }

  class { 'nvm':
    user         => $pwa_user,
    install_node => '9.10.1',
  }

  file {"${docker_build_dir}/$pwa_user":
    ensure => directory,
    owner  => $pwa_user,
    mode   => '0777',
  }


  file { '/usr/local/bin/build-pwa':
    content => epp('pwa/build-pwa.sh.epp',{
      target => $target,
    }),
    mode => '0775',
  } 

  vcsrepo { "${pwa_build_dir}":
      ensure   => latest,
      user     => $pwa_user,
      revision => $branch,
      provider => git,
      source   => 'https://github.com/alpheios-project/pwa-prototype.git',
      notify   => Exec['build-pwa-source'],
  }

  file { "${pwa_build_dir}/docker-nginx-config/certs":
    ensure => directory,
    require => Vcsrepo[$pwa_build_dir],
  }

  file { "${pwa_build_dir}/docker-nginx-config/conf.d/default.conf":
    content => epp('pwa/default.conf.epp',{
      server_name => $mode,
    }),
    owner  => $pwa_user,
  }


  file { "${pwa_build_dir}/docker-nginx-config/certs/STAR_alpheios.net_chained.crt":
    content => lookup('ssl_cert_chained'),
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
    require     => Class['nvm'],
  }

  exec { 'remove-pwa-image':
      command     => "docker rmi -f ${mode}",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image[$mode],
  }

  docker::image { $mode:
    ensure      => present,
    docker_file => "${pwa_build_dir}/docker-image/Dockerfile",
    notify      => Docker::Run[$mode],
    force       => true,
  }
}
