# Be an eXist repository
class role::pwa {
  include profile::common
  include profile::pwa::build
  include profile::pwa::server
}
