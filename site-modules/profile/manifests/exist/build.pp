# Build the Handle Server Docker image
class profile::exist::build {
  include profile::docker::builder
  include exist::build
}
