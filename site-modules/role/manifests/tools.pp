# Be an eXist repository
class role::tools {
  include profile::common
  include profile::tools::build
  include profile::tools::server

  firewall { '100 Web Service Access':
    proto  => 'tcp',
    dport  => ['80','443'],
    action => 'accept',
  }
}
