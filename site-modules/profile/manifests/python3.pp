# Install Python 3
class profile::python3 {
  include apt

  apt::ppa { 'ppa:ondrej/apache2': }

  class {'apache': 
    require        => Apt::Ppa['ppa:ondrej/apache2'],
    apache_version => "2.5"
  }

  class { 'python':
    version    => 'python3.5',
    pip        => 'present',
    dev        => 'present',
    virtualenv => 'present',
    gunicorn   => 'present',
  }
  ensure_packages(hiera('python3_mod_wsgi'))

  class { 'apache::mod::wsgi':
    mod_path     => 'mod_wsgi.so-3.5',
    package_name => hiera('python3_mod_wsgi'),
  }

  class { 'apache::mod::http2':
  }

}
