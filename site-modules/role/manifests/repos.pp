# Be an eXist repository
class role::repos {
  include profile::common
  include profile::exist::build
  include profile::exist::server
}
