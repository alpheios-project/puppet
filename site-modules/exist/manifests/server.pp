# Run the eXist  Server container
class exist::server {
  $docker_run_dir = lookup('docker_run_dir', String)
  $exist_run_dir = "${docker_run_dir}/exist"

  file { $exist_run_dir:
    ensure => directory,
  }

  docker::run { 'lexsvc':
    ensure  => present,
    image   => "lexsvc:latest",
    ports   => [
      "8080:8080",
    ],
  }

  firewall { '100 Allow web traffic for handle':
    proto  => 'tcp',
    dport  => 8080,
    action => 'accept',
  }

}
