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
    }),
    notify  => Exec['remove-docker-image'],
  }

  file { "${build_dir}/Dockerfile":
    content => epp('profile/varnishlex/Dockerfile.epp',{
      'cachesize' => '1G'
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
