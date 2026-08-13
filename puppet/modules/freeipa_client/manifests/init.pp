class freeipa_client (
  String $ipa_server     = 'freeipa-server.pme.local',
  String $ipa_domain     = 'pme.local',
  String $ipa_realm      = 'PME.LOCAL',
  String $admin_password = lookup('freeipa_client::admin_password'),
) {

  case $facts['os']['family'] {

    'Debian': {
      package { 'freeipa-client':
        ensure => installed,
      }
    }

    'RedHat': {
      package { 'ipa-client':
        ensure => installed,
      }
    }

    default: {
      fail("freeipa_client module does not support OS family: ${facts['os']['family']}")
    }
  }

  exec { 'join-freeipa-domain':
    command => "/usr/sbin/ipa-client-install --domain=${ipa_domain} --server=${ipa_server} --realm=${ipa_realm} --principal=admin --password='${admin_password}' --mkhomedir --unattended",
    creates => '/etc/ipa/default.conf',
    require => Package[$facts['os']['family'] ? { 'Debian' => 'freeipa-client', 'RedHat' => 'ipa-client' }],
  }
}