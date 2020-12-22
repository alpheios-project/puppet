# Be a texts server
class role::texts {
  include profile::common
  include profile::python3
  include capitains
  #  include profile::blacklab::docker
  # include profile::blacklab::apache
}
