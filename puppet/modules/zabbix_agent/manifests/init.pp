class zabbix_agent {
  # Add the official Zabbix repository with an expanded system PATH
  exec { 'add-zabbix-repo':
    command => 'wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu22.04_all.deb -O /tmp/zabbix-release.deb && dpkg -i /tmp/zabbix-release.deb',
    path    => ['/usr/local/sbin', '/usr/sbin', '/sbin', '/usr/bin', '/bin'],
    creates => '/etc/apt/sources.list.d/zabbix.list',
  }

  # Force an APT update ONLY after the repo file is placed
  exec { 'zabbix-apt-update':
    command     => 'apt-get update',
    path        => ['/usr/local/sbin', '/usr/sbin', '/sbin', '/usr/bin', '/bin'],
    subscribe   => Exec['add-zabbix-repo'],
    refreshonly => true,
  }

  # Install the agent, ensuring the cache updated first
  package { 'zabbix-agent':
    ensure  => installed,
    require => [Exec['add-zabbix-repo'], Exec['zabbix-apt-update']],
  }

  # Manage configuration profile
  file { '/etc/zabbix/zabbix_agentd.conf':
    ensure  => file,
    content => template('zabbix_agent/zabbix_agentd.conf.erb'),
    require => Package['zabbix-agent'],
    notify  => Service['zabbix-agent'],
  }

  # Ensure service is locked on and running
  service { 'zabbix-agent':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => File['/etc/zabbix/zabbix_agentd.conf'],
  }
}