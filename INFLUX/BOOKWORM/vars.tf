variable "pm_api_url" {
    type = string
}
variable "pm_api_token_id" {
    type = string
}
variable "pm_api_token_secret" {
    type = string
    sensitive = true
}
variable "pm_tls_insecure" {
    type = string
}
variable "proxmox_host" {
    type = string
    default = "pve"
}
variable "proxmox_ip" {
    type = string
}
variable "count_master" {
    type = string
    default = "2"
}
variable "vm_id_master_prefix" {
    type = string
    default = "20"
}
variable "cpu_cores" {
    type = string
    default = "2"
}
variable "memory_master" {
    type = string
    default = "4096"
}
variable "template_name" {
    type = string
    default = "debian"
}
variable "ci_custom" {
    type = string
}
variable "ssh_user" {
    type = string
    default = "kadmin"
}
variable "ssh_key" {
    type = string
}
variable "vm_storage" {
    type = string
}
variable "nic_name" {
    type = string
    default = "vmbr0"
}
variable "ip_master" {
    type = string
}
variable "ipmask" {
    type = string
}
variable "gateway" {
    type = string
}
variable "dns_home_var" {
    type = string
}
variable "search_domains_home_var" {
    type = string
}
