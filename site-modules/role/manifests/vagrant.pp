# Be a Vagrant box
class role::vagrant {
  include profile::common
  include profile::exist::server
}
