# Be an eXist repository
class role::pwadev {
  include profile::common
  include profile::docker::builder
  include profile::docker::runner
  class { 'pwa::build': 
    mode   => 'pwa-dev',
    branch => 'issues474641',
  }
  class { 'pwa::server':
    mode   => 'pwa-dev',
  }
}
