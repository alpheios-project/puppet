# Dependencies for Capitains
class capitains::dependencies {
  class { 'redis': }

  ensure_packages(hiera('capitains::deps'))

  file { "/etc/gunicorn.d":
    ensure => directory,
  }

}
