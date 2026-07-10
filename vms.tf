resource "vmworkstation_vm" "puppet_freeipa" {
  sourceid     = var.template_id
  denomination = "puppet_freeipa_v"
  description  = "Puppet Master + FreeIPA Server"
  path         = "D:\\puppet_freeipa_v\\puppet_freeipa_v.vmx"
  processors   = 2
  memory       = 3072
}

resource "vmworkstation_vm" "elk_server" {
  sourceid     = var.template_id
  denomination = "elk_server_v"
  description  = "Elasticsearch + Logstash + Kibana"
  path         = "D:\\elk_server_v\\elk_server_v.vmx"
  processors   = 4
  memory       = 6144
}

resource "vmworkstation_vm" "zabbix_server" {
  sourceid     = var.template_id
  denomination = "zabbix_server_v"
  description  = "Zabbix Monitoring Server"
  path         = "D:\\zabbix_server_v\\zabbix_server_v.vmx"
  processors   = 2
  memory       = 2048
}

resource "vmworkstation_vm" "web_server" {
  sourceid     = var.template_id
  denomination = "web_server_v"
  description  = "Apache Web Server - PME App"
  path         = "D:\\web_server_v\\web_server_v.vmx"
  processors   = 2
  memory       = 2048
}

resource "vmworkstation_vm" "db_server" {
  sourceid     = var.template_id
  denomination = "db_server_v"
  description  = "MySQL Database Server"
  path         = "D:\\db_server_v\\db_server_v.vmx"
  processors   = 2
  memory       = 2048
}