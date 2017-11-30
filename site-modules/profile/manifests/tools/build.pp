# Build the Handle Server Docker image
class profile::tools::build {
  include profile::docker::builder
  include tools::build
}
