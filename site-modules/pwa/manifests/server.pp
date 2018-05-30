# Run the  Server container
class pwa::server($mode = 'pwa') {

  $docker_run_dir = lookup('docker_run_dir', String)
  $docker_build_dir = lookup('docker_build_dir', String)
  $pwa_run_dir = "${docker_run_dir}/${mode}"
  $pwa_user = 'balmas'
  $pwa_build_dir = "${docker_build_dir}/$pwa_user/${mode}"

  file { $pwa_run_dir:
    ensure => directory,
  }

  docker::run { $mode:
    ensure  => present,
    image   => "${mode}:latest",
    ports   => [
      "80:80",
      "443:443",
    ],
    volumes => [ 
      "${pwa_build_dir}/dist:/usr/share/nginx/html",
      "${pwa_build_dir}/docker-nginx-config/conf.d:/etc/nginx/conf.d",
      "${pwa_build_dir}/docker-nginx-config/certs:/etc/nginx/ssl",
    ]
  }

  firewall { '100 Allow web traffic for pwa':
    proto  => 'tcp',
    dport  => [80,443],
    action => 'accept',
  }

}
