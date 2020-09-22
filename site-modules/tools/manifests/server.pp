# Run the eXist  Server container
class tools::server {

  $docker_run_dir = lookup('docker_run_dir', String)
  $exist_run_dir = "${docker_run_dir}/tools"
  $tokenizer_run_dir = "${docker_run_dir}/tokenizer"

  file { $exist_run_dir:
    ensure => directory,
  }

  file { $tokenizer_run_dir:
    ensure => directory,
  }

  docker::run { 'editors':
    ensure  => present,
    image   => "editors:latest",
    ports   => [
      "8080:8080",
    ],
  }

  docker::run { 'tokenizer':
    ensure  => present,
    image   => "tokenizer:latest",
    command => "gunicorn --bind 0.0.0.0:5000 manage:app",
    ports   => [
      "5000:5000",
    ],
  }

  firewall { '100 Allow web traffic for handle':
    proto  => 'tcp',
    dport  => 8080,
    action => 'accept',
  }

  firewall { '100 Allow web traffic for tokenizer':
    proto  => 'tcp',
    dport  => 5000,
    action => 'accept',
  }

}
