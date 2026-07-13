node 'web-server.pme.local' {
  include apache
  include zabbix_agent
}

node 'db-server.pme.local' {
  include mysql
  include zabbix_agent
}

node 'zabbix-server.pme.local' {
  include zabbix_agent
}

node 'elk-server.pme.local' {
  include zabbix_agent
}

node 'puppet-freeipa.pme.local' {
  include zabbix_agent
}

node default {
  notify { 'No specific role configured for this node': }
}