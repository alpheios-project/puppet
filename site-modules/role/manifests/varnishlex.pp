class role::varnishlex {
  include profile::common
  include profile::lexdata
  include profile::varnishlex::docker
  include profile::varnishlex::apache
}
