class profile::ats {
  include profile::ssl
  include profile::python3

  $app_root = '/usr/local/alpheios-translation-service'
  $repos = 'https://github.com/alpheios-project/alpheios-translation-service'

  vcsrepo { $app_root:
    ensure   => latest,
    revision => 'master',
    provider => git,
    source   => $repos,
    notify  => Python::Virtualenv[$app_root],
  }

  file { "/etc/gunicorn.d":
    ensure => directory,
  }

  file { "${app_root}/requirements.txt":
    ensure  => file,
    source  => 'puppet:///modules/profile/ats/requirements.txt',
    require => Vcsrepo[$app_root],
    notify  => Python::Virtualenv[$app_root],
  }


  file { "${app_root}/app.py":
    ensure  => file,
    content => epp('profile/ats/app.py.epp', {
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
    notify       => Exec['restart-ats-gunicorn'],
    require      => File['/etc/gunicorn.d'],
  }

  python::gunicorn { 'ats-vhost':
    ensure     => present,
    virtualenv => "${app_root}/venv",
    dir        => $app_root,
    timeout    => 120,
    bind       => 'localhost:5000',
    appmodule  => 'app:app',
    owner      => 'www-data',
    group      => 'www-data',
  }

  exec { 'restart-ats-gunicorn':
    command     => '/usr/sbin/service gunicorn restart',
    refreshonly => true,
    require     => Python::Gunicorn['ats-vhost'],
  }

  $proxy_pass = {
    'path'    => '/',
    'url'     => 'http://localhost:5000/',
  }

  $headers = [
      "set Access-Control-Allow-Origin '*'",
      "set Access-Control-Allow-Methods 'GET, POST, OPTIONS'"
  ]

  apache::vhost { 'ats':
    servername => 'ats.alpheios.net',
    port       => '80',
    docroot    => '/var/www/vhost',
    proxy_pass => [ $proxy_pass ],
    headers    => $headers,
  }

  apache::vhost { 'ats-ssl':
    servername => 'ats.alpheios.net',
    port       => '443',
    docroot    => '/var/www/vhost',
    proxy_pass => [ $proxy_pass ],
    headers    => $headers,
    ssl        => true,
    ssl_cert   => '/etc/ssl/certs/STAR_alpheios.net.crt',
    ssl_key    => '/etc/ssl/private/Alpheios.key',
    ssl_chain  => '/etc/ssl/certs/ca-bundle-client.crt',
  }

  firewall { '100 ATS Service Access':
    proto  => 'tcp',
    dport  => ['80','443'],
    action => 'accept',
  }

}
