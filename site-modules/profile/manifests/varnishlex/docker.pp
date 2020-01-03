class profile::varnishlex::docker {
  include profile::docker::builder
  include profile::docker::runner
  include profile::ssl

  $docker_build_dir = lookup('docker_build_dir', String)
  $build_dir = "${docker_build_dir}/lexdocker"

  $docker_run_dir = lookup('docker_run_dir', String)
  $run_dir = "${docker_run_dir}/lexdocker"

  file { $exist_run_dir:
    ensure => directory,
  }

  vcsrepo { "${build_dir}":
      ensure   => latest,
      revision => 'master',
      provider => git,
      source   => 'https://github.com/alpheios-project/lex-docker.git',
      notify  => Exec['remove-exist-image'],
  }

  exec { 'remove-exist-image':
      command     => "docker rmi -f lexvarnish",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image['lexvarnish'],
  }

  docker::image { 'lexvarnish':
    ensure     => present,
    docker_dir => "${exist_build_dir/varnish}",
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

  class {'apache':
    log_formats   => { combined => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D'},
    default_vhost => false,
  }

  $proxy_pass = {
    'path'    => '/exist/',
    'url'     => 'http://localhost:80/exist/',
  }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'"
  ]

  apache::vhost { 'repos1-ssl':
    port                => '443',
    servername          => 'repos-v.alpheios.net',
    docroot             => '/var/www/html',
    proxy_preserve_host => 'On',
    proxy_pass          => [ $proxy_pass ],
    headers    => $headers,
    ssl        => true,
    ssl_cert   => '/etc/ssl/certs/STAR_alpheios.net.crt',
    ssl_key    => '/etc/ssl/private/Alpheios.key',
    ssl_chain  => '/etc/ssl/certs/ca-bundle-client.crt',
  }

  firewall { '100 Web Service Access':
    proto  => 'tcp',
    dport  => ['80','443'],
    action => 'accept',
  }

}
