# Run the  Server container
class pwa::server {
  include apache 

  $docker_run_dir = lookup('docker_run_dir', String)
  $docker_build_dir = lookup('docker_build_dir', String)
  $pwa_run_dir = "${docker_run_dir}/pwa"
  $pwa_user = 'balmas'
  $pwa_build_dir = "${docker_build_dir}/$pwa_user/pwa"

  file { $pwa_run_dir:
    ensure => directory,
  }

  docker::run { 'pwa':
    ensure  => present,
    image   => "pwa:latest",
    ports   => [
      "8020:80",
      "8120:443",
    ],
    volumes => [ 
      "${pwa_build_dir}/dist:/usr/share/nginx/html",
      "${pwa_build_dir}/docker-nginx-config/conf.d:/etc/nginx/conf.d",
      "${pwa_build_dir}/docker-nginx-config/certs:/etc/nginx/ssl",
    ]
  }

  firewall { '100 Allow web traffic for pwa':
    proto  => 'tcp',
    dport  => [8020,8120],
    action => 'accept',
  }

}
