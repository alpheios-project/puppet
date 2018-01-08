# Dependencies for Capitains
class capitains::dependencies {


  class { 'redis': 
    stop_writes_on_bgsave_error => false
  }

  ensure_packages(hiera('capitains::deps'))

  file { "/etc/gunicorn.d":
    ensure => directory,
  }

}
