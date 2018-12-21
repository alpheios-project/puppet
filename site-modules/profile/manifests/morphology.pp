# Be the Morphology server
class profile::morphology {
  include profile::ssl
  include profile::morphology::morpheus
  include profile::morphology::wordsxml
  include profile::morphology::aramorph
  include profile::python3
  class { 'redis': 
    maxmemory        => '4gb',
    maxmemory_policy => 'allkeys-lru',
  }

  $app_root = '/usr/local/morphsvc'
  $repos = 'https://github.com/alpheios-project/morphsvc'
  $redis_host = 'localhost'

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
    source  => 'puppet:///modules/profile/morphology/requirements.txt',
    require => Vcsrepo[$app_root],
    notify  => Python::Virtualenv[$app_root],
  }

  file { "${app_root}/morphsvc/production.cfg":
    ensure  => file,
    content => epp('profile/morphology/production.cfg.epp', {
      'morpheus_path'         => hiera('morpheus::binary_path'),
      'morpheus_stemlib_path' => '/usr/local/morpheus/dist/stemlib',
      'wordsxml_path'         => hiera('wordsxml::binary_path'),
      'aramorph_url'          => 'http://localhost:8088/perl/aramorph2?word=',
    }),
    require => Vcsrepo[$app_root],
    notify  => Python::Virtualenv[$app_root],
  }

  file { "${app_root}/app.py":
    ensure  => file,
    content => epp('profile/morphology/app.py.epp', {
      'redis_host'  => $redis_host,
      'redis_port'  => '6379',
      'config_file' => 'production.cfg',
    }),
    require => Vcsrepo[$app_root],
    notify  => Python::Virtualenv[$app_root],
  }

  vcsrepo { '/usr/local/lexical-tests':
    ensure   => latest,
    revision => 'master',
    provider => git,
    source   => "https://github.com/alpheios-project/lexical-tests",
  }

  python::virtualenv { $app_root:
    ensure       => present,
    version      => '3',
    requirements => "${app_root}/requirements.txt",
    venv_dir     => "${app_root}/venv",
    cwd          => $app_root,
    notify       => Exec['restart-morph-gunicorn'],
    require      => File['/etc/gunicorn.d'],
  }

  python::gunicorn { 'morphology-vhost':
    ensure      => present,
    osenv       => {
      'LANG'    => 'en_US.utf8',
      'LANG'    => 'en_US.UTF-8',
      'LC_LANG' => 'en_US.UTF-8',
      'LC_ALL'  => 'en_US.UTF-8',
    },
    virtualenv        => "${app_root}/venv",
    dir               => $app_root,
    timeout           => 120,
    bind              => 'localhost:5000',
    workers           => 3,
    access_log_format => '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s',
    accesslog         => '/var/log/gunicorn/access.log',
    appmodule         => 'app:app',
    owner             => 'www-data',
    group             => 'www-data',
    args              => [
     '--worker-class=gevent',
     '--worker-connections=50'
    ] 

  }

  exec { 'restart-morph-gunicorn':
    command     => '/usr/sbin/service gunicorn restart',
    refreshonly => true,
    require     => Python::Gunicorn['morphology-vhost'],
  }

  $proxy_pass = {
    'path'    => '/api/v1',
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
    proxy_pass => [ $proxy_pass ],
    rewrites   => [ 
      {'rewrite_rule' => [ '/legacy/latin http://localhost:5000/analysis/word?lang=lat&engine=wleg [P,L,QSA]']},
      {'rewrite_rule' => [ '/legacy/greek http://localhost:5000/analysis/word?lang=grc&engine=mgrcleg [P,L,QSA]']},
      {'rewrite_rule' => [ '/legacy/aramorph2 http://localhost:5000/analysis/word?lang=ara&engine=amleg [P,L,QSA]']},
    ],
    aliases   => [
      { alias => '/lexical-tests',
        path  => '/usr/local/lexical-tests',
      }
    ],
    headers    => $headers,
  }

  apache::vhost { 'morphology-ssl':
    servername => 'morph.alpheios.net',
    port       => '443',
    docroot    => '/var/www/vhost',
    proxy_pass => [ $proxy_pass ],
    rewrites   => [ 
      {'rewrite_rule' => [ '/legacy/latin http://localhost:5000/analysis/word?lang=lat&engine=wleg [P,L,QSA]']},
      {'rewrite_rule' => [ '/legacy/greek http://localhost:5000/analysis/word?lang=grc&engine=mgrcleg [P,L,QSA]']},
      {'rewrite_rule' => [ '/legacy/aramorph2 http://localhost:5000/analysis/word?lang=ara&engine=amleg [P,L,QSA]']},
    ],
    headers    => $headers,
    aliases   => [
      { alias => '/lexical-tests',
        path  => '/usr/local/lexica-tests',
      }
    ],
    ssl        => true,
    ssl_cert   => '/etc/ssl/certs/STAR_alpheios.net.crt',
    ssl_key    => '/etc/ssl/private/Alpheios.key',
    ssl_chain  => '/etc/ssl/certs/ca-bundle-client.crt',
  }

  firewall { '100 Morphology Service Access':
    proto  => 'tcp',
    dport  => ['80','443'],
    action => 'accept',
  }

  cron { 'run-cloudwatch':
    ensure  => present,
    command => '/etc/puppetlabs/code/environments/production/aws-scripts-mon/mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --disk-space-util --disk-path=/ --from-cron',
    minute  => '5'
  }


}
