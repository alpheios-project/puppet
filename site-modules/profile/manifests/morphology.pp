# Be the Morphology server
class site::profiles::morphology {
  include site::profiles::morphology::morpheus
  include site::profiles::morphology::wordsxml
  include site::profiles::python3
  class { 'redis': 
    maxmemory        => '4gb'
    maxmemory_policy => 'allkeys-lru',
  }

  $app_root = '/usr/local/morphsvc'
  $repos = 'https://github.com/alpheios-project/morphsvc'
  $redis_host = 'localhost'

  vcsrepo { $app_root:
    ensure   => latest,
    revision => 'v1.0.0'
    provider => git,
    source   => $repos,
  }

  file { "${app_root}/requirements.txt":
    ensure  => file,
    source  => 'puppet:///modules/site/profiles/morphology/requirements.txt',
    require => Vcsrepo[$app_root],
    notify  => Python::Virtualenv[$app_root],
  }

  file { "${app_root}/morphsvc/production.cfg":
    ensure  => file,
    content => epp('site/profiles/morphology/production.cfg.epp', {
      'morpheus_path'         => hiera('morpheus::binary_path'),
      'morpheus_stemlib_path' => '/usr/local/morpheus/stemlib',
      'wordsxml_path'         => hiera('wordsxml::binary_path'),
      'aramorph_url'          => 'http://alpheios.net/perl/aramorph-test?word=',
    }),
    require => Vcsrepo[$app_root],
    notify  => Python::Virtualenv[$app_root],
  }

  file { "${app_root}/app.py":
    ensure  => file,
    content => epp('site/profiles/morphology/app.py.epp', {
      'redis_host'  => $redis_host,
      'redis_port'  => '6379',
      'config_file' => 'production.cfg',
    }),
    require => Vcsrepo[$app_root],
    notify  => Python::Virtualenv[$app_root],
  }

  python::virtualenv { $app_root:
    ensure       => present,
    version      => '3',
    requirements => "${app_root}/requirements.txt",
    venv_dir     => "${app_root}/venv",
    cwd          => $app_root,
    notify       => Exec['restart-morph-gunicorn'],
  }

  python::gunicorn { 'morphology-vhost':
    ensure     => present,
    virtualenv => "${app_root}/venv",
    dir        => $app_root,
    timeout    => 120,
    bind       => 'localhost:5000',
    appmodule  => 'app:app',
    owner      => 'www-data',
    group      => 'www-data',
  }

  exec { 'restart-morph-gunicorn':
    command     => '/usr/sbin/service gunicorn restart',
    refreshonly => true,
    require     => Python::Gunicorn['morphology-vhost'],
  }

  $proxy_pass = {
    'path'    => '/',
    'url'     => 'http://localhost:5000/',
  }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'"
  ]

  apache::vhost { 'morphology':
    servername => 'morph.alpheios.net',
    port       => '80',
    docroot    => '/var/www/vhost',
    proxy_pass => [$proxy_pass],
    headers    => $headers,
  }

  firewall { '100 Morphology Service Access':
    proto  => 'tcp',
    dport  => ['80'],
    action => 'accept',
  }

}
