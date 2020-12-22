class role::blacklab {
  include profile::common
  include profile::blacklab::docker
  include profile::blacklab::apache
}
