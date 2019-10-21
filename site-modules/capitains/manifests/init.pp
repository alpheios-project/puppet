# Capitains
class capitains($www_root,
                $data_root,
                $app_root,
                $redis_host,
                $repos,
                $workdir,
                $venvdir,
                $ci_url) {
  include capitains::dependencies
  include capitains::apache
  include capitains::repos

  class { 'nvm':
     user => 'root',
     nvm_dir      => '/opt/nvm',
     version      => 'v0.29.0',
     profile_path => '/etc/profile.d/nvm.sh',
     install_node => '12.6.0',
  }

  vcsrepo { $app_root:
     ensure   => latest,
     revision => '2019-10-21',
     provider => git,
     source   => "https://github.com/alpheios-project/alpheios_nemo_ui",
     notify   => Python::Virtualenv[$app_root],
  }


  file { $capitains::data_root:
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
  }

  file { "${app_root}/manager.py":
    content => template('capitains/manager.py.erb'),
    notify  => Python::Virtualenv[$capitains::app_root],
  }

  file { "${app_root}/app.py":
    content           => epp('capitains/app.py.epp',{
      'data_root'     => $data_root,
      'redis_host'    => $redis_host,
      'client_id'     => lookup('auth0_clientid',String),
      'client_secret' => lookup('auth0_clientsecret',String),
      'secret_key'    => lookup('flask_sessionsecret',String),
      'domain'        =>  lookup('capitains::domain', String),
    }),
    notify  => Python::Virtualenv[$capitains::app_root],
  }

  file { "${app_root}/hookclean.py":
    content => template('capitains/hookclean.py.erb'),
  }

  file { "${app_root}/install-dev.sh":
    content => template('capitains/install-dev.sh.erb'),
    mode    => "0755",
    notify => Python::Virtualenv[$app_root],
  }

  file { "${app_root}/requirements.txt":
    content => template('capitains/requirements.txt.erb'),
    require    => Vcsrepo[$app_root],
    notify => Python::Virtualenv[$app_root],
  }

  file { "${app_root}/alpheios_nemo_ui/data/assets/js/env.js":
    content        => epp('capitains/env.js.epp', {
      'domain'         =>  lookup('capitains::domain', String),
      'wordlist_url' =>  lookup('apis::wordlist_url', String),
      'settings_url' =>  lookup('apis::settings_url', String)
    }),
    require    => Vcsrepo[$app_root],
    notify => Python::Virtualenv[$app_root],
  }


  python::virtualenv { $capitains::app_root:
    ensure       => present,
    require      => Class['capitains::dependencies'],
    version      => '3',
    requirements => "${capitains::app_root}/requirements.txt",
    venv_dir     => $capitains::venvdir,
    cwd          => $capitains::app_root,
    notify       => Exec['build-capitains-dev'],
  }

  exec { 'build-capitains-dev':
    cwd     => $capitains::app_root,
    notify  => Exec['restart-gunicorn'],
    command => "${app_root}/install-dev.sh",
    require => Python::Virtualenv[$capitains::app_root],
    refreshonly => true,
  }

  python::gunicorn { 'vhost':
    ensure     => present,
    virtualenv => $capitains::venvdir,
    dir        => $capitains::app_root,
    bind       => 'localhost:5000',
    osenv      => {'LANG' => 'en_US.UTF-8', 'LC_ALL' => 'en_US.UTF-8'},
    appmodule  => 'app:app',
    owner      => 'www-data',
    group      => 'www-data',
  }

  exec { 'restart-gunicorn':
    command     => '/usr/sbin/service gunicorn restart',
    refreshonly => true,
    require     => Python::Gunicorn['vhost'],
  }
}
