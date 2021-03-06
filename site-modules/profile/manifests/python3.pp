# Install Python 3
class profile::python3 {
  include profile::ssl

  class {'apache':
    default_vhost => false,
    log_formats   => { combined => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D'},
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
