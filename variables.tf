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

variable "vm_base_path" {
  description = "Base path where VMs will be stored"
  type        = string
  default     = "D:\\"
}