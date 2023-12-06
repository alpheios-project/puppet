# Be a texts server
class role::texts {
  include profile::blacklab::docker
  include profile::blacklab::apache
}
