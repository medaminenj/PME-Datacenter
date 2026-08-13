class filebeat {

  case $facts['os']['family'] {

    'Debian': {
      exec { 'add-elastic-gpg-key':
        command => 'wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elastic.gpg',
        path    => ['/usr/local/sbin', '/usr/sbin', '/sbin', '/usr/bin', '/bin'],
        creates => '/usr/share/keyrings/elastic.gpg',
      }

      exec { 'add-elastic-repo':
        command => 'echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" > /etc/apt/sources.list.d/elastic-8.x.list',
        path    => ['/usr/local/sbin', '/usr/sbin', '/sbin', '/usr/bin', '/bin'],
        creates => '/etc/apt/sources.list.d/elastic-8.x.list',
        require => Exec['add-elastic-gpg-key'],
      }

      exec { 'elastic-apt-update':
        command     => 'apt-get update',
        path        => ['/usr/local/sbin', '/usr/sbin', '/sbin', '/usr/bin', '/bin'],
        subscribe   => Exec['add-elastic-repo'],
        refreshonly => true,
      }

      package { 'filebeat':
        ensure  => installed,
        require => [Exec['add-elastic-repo'], Exec['elastic-apt-update']],
      }
    }

    'RedHat': {
      exec { 'add-elastic-repo':
        command => 'rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch',
        path    => ['/usr/local/sbin', '/usr/sbin', '/sbin', '/usr/bin', '/bin'],
      }

      file { '/etc/yum.repos.d/elastic.repo':
        ensure  => file,
        content => "[elastic-8.x]\nname=Elastic repository for 8.x packages\nbaseurl=https://artifacts.elastic.co/packages/8.x/yum\ngpgcheck=1\ngpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch\nenabled=1\nautorefresh=1\ntype=rpm-md\n",
        require => Exec['add-elastic-repo'],
      }

      package { 'filebeat':
        ensure  => installed,
        require => File['/etc/yum.repos.d/elastic.repo'],
      }
    }

    default: {
      fail("filebeat module does not support OS family: ${facts['os']['family']}")
    }
  }

  file { '/etc/filebeat/filebeat.yml':
    ensure  => file,
    content => template('filebeat/filebeat.yml.erb'),
    require => Package['filebeat'],
    notify  => Service['filebeat'],
  }

  service { 'filebeat':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => File['/etc/filebeat/filebeat.yml'],
  }
}