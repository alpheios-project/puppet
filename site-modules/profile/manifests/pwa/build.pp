class profile::pwa::build {
  include profile::docker::builder
  class {'pwa::build': 
    branch => 'v0.52-build',
  }
}
