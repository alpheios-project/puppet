# Dependencies for Capitains
class capitains::dependencies {


  class { 'redis': 
    stop_writes_on_bgsave_error => false,
    maxmemory        => '1gb',
    maxmemory_policy => 'allkeys-lru',
  }

  ensure_packages(hiera('capitains::deps'))

  file { "/etc/gunicorn.d":
    ensure => directory,
  }

}
