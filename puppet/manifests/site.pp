node 'web-server.pme.local' {
  include apache
  include zabbix_agent
  include freeipa_client
  include filebeat
}

node 'db-server.pme.local' {
  include mysql
  include zabbix_agent
  include freeipa_client
  include filebeat
}

node 'zabbix-server.pme.local' {
  include zabbix_agent
  include freeipa_client
  include filebeat
}

node 'elk-server.pme.local' {
  include zabbix_agent
  include freeipa_client
  include filebeat
}

node 'puppet-freeipa.pme.local' {
  include zabbix_agent
  include freeipa_client
  include filebeat
}

node 'freeipa-server.pme.local' {
  include zabbix_agent
  include filebeat
}

node default {
  notify { 'No specific role configured for this node': }
}