# Be an eXist repository
class role::pwa-dev {
  include profile::common
  include profile::pwa::build
  include profile::pwa::server
}
