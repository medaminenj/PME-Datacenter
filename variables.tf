variable "vmware_user" {
  description = "VMware REST API username"
  type        = string
}

variable "vmware_password" {
  description = "VMware REST API password"
  type        = string
  sensitive   = true
}

variable "template_id" {
  description = "ID of the ubuntu-22-template VM"
  type        = string
  default     = "HG0KIB8T9MLAUBMQF6GN697SNI660EJD"
}

variable "rocky_template_id" {
  description = "ID of the freeipa-template VM (Rocky Linux, used for FreeIPA server)"
  type        = string
  default     = "NVRAINUN0VA64S8A8QS1T5VDJKQONN4R"
}

variable "vm_base_path" {
  description = "Base path where VMs will be stored"
  type        = string
  default     = "D:\\"
}