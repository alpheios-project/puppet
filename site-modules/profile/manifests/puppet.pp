# Set up Puppet config and cron run
class profile::puppet {
  service { ['puppet', 'mcollective', 'pxp-agent']:
    ensure => stopped, # Puppet runs from cron
    enable => false,
  }

  cron { 'run-puppet':
    ensure  => present,
    command => '/usr/local/bin/run-puppet',
    minute  => absent,
    hour    => '2',
    weekday => '0'
  }

  $scripts = [
    'papply',
    'plock',
    'punlock',
    'run-puppet',
  ]

  $scripts.each | $script | {
    file { "/usr/local/bin/${script}":
      source => "puppet:///modules/profile/puppet/${script}.sh",
      mode   => '0755',
    }
  }

  file_line { 'disable reports':
    path  => '/etc/puppetlabs/puppet/puppet.conf',
    line  => 'report = false',
  }

  file { '/tmp/puppet.lastrun':
    content => strftime('%F %T'),
    backup  => false,
  }

  firewall { '100 allow SSH (for Git)':
    chain  => 'OUTPUT',
    state  => ['NEW'],
    dport  => '22',
    proto  => 'tcp',
    action => 'accept',
  }
}
