class zabbix_agent {

  $hostname = $facts['networking']['hostname']

  case $facts['os']['family'] {

    'Debian': {
      # Add the official Zabbix repository (Ubuntu/Debian)
      exec { 'add-zabbix-repo':
        command => 'wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu22.04_all.deb -O /tmp/zabbix-release.deb && dpkg -i /tmp/zabbix-release.deb',
        path    => ['/usr/local/sbin', '/usr/sbin', '/sbin', '/usr/bin', '/bin'],
        creates => '/etc/apt/sources.list.d/zabbix.list',
      }

      exec { 'zabbix-apt-update':
        command     => 'apt-get update',
        path        => ['/usr/local/sbin', '/usr/sbin', '/sbin', '/usr/bin', '/bin'],
        subscribe   => Exec['add-zabbix-repo'],
        refreshonly => true,
      }

      package { 'zabbix-agent':
        ensure  => installed,
        require => [Exec['add-zabbix-repo'], Exec['zabbix-apt-update']],
      }
    }

    'RedHat': {
      # Add the official Zabbix repository (Rocky/RHEL/AlmaLinux/CentOS)
      exec { 'add-zabbix-repo':
        command => 'rpm -Uvh https://repo.zabbix.com/zabbix/7.0/rhel/9/x86_64/zabbix-release-7.0-1.el9.noarch.rpm',
        path    => ['/usr/local/sbin', '/usr/sbin', '/sbin', '/usr/bin', '/bin'],
        creates => '/etc/yum.repos.d/zabbix.repo',
      }

      exec { 'zabbix-dnf-update':
        command     => 'dnf clean all && dnf makecache',
        path        => ['/usr/local/sbin', '/usr/sbin', '/sbin', '/usr/bin', '/bin'],
        subscribe   => Exec['add-zabbix-repo'],
        refreshonly => true,
      }

      package { 'zabbix-agent':
        ensure  => installed,
        require => [Exec['add-zabbix-repo'], Exec['zabbix-dnf-update']],
      }
    }

    default: {
      fail("zabbix_agent module does not support OS family: ${facts['os']['family']}")
    }
  }

  # Config file management (same for both OS families)
  file { '/etc/zabbix/zabbix_agentd.conf':
    ensure  => file,
    content => template('zabbix_agent/zabbix_agentd.conf.erb'),
    require => Package['zabbix-agent'],
    notify  => Service['zabbix-agent'],
  }

  service { 'zabbix-agent':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => File['/etc/zabbix/zabbix_agentd.conf'],
  }
}