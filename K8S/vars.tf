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
variable "count_worker" {
    type = string
    default = "1"
}
variable "vm_id_master_prefix" {
    type = string
    default = "20"
}
variable "vm_id_worker_prefix" {
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
variable "memory_worker" {
    type = string
    default = "8196"
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
variable "ip_worker" {
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
variable "dns_sst_var" {
    type = string
}
variable "search_domains_home_var" {
    type = string
}
variable "search_domains_sst_var" {
    type = string
}
