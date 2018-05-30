# Be an eXist repository
class role::pwadev {
  include profile::common
  include profile::docker::builder
  include profile::docker::runner
  class { 'pwa::build': 
    mode   => 'pwa-dev',
    branch => 'pwa-ui',
  }
  class { 'pwa::server':
    mode   => 'pwa-dev',
  }
}
