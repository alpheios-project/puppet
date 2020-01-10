class role::varnishmorph {
  include profile::common
  include profile::varnishmorph::docker
  include profile::varnishmorph::apache
}
