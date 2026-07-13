node 'web-server.pme.local' {
  include apache
}

node 'db-server.pme.local' {
  include mysql
}

node default {
  notify { 'No specific role configured for this node': }
}