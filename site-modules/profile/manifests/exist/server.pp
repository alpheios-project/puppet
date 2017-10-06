# Run the Handle Server container
class profile::exist::server {
  include profile::docker::runner
  include exist::server
}
