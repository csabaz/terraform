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
variable "proxmox_ip" {
    type = string
}
variable "ssh_user" {
    type = string
    default = "kadmin"
}
variable "ssh_key" {
    type = string
}
variable "name" {
    type = string
    default = "icinga"
}
variable "vm_id_prefix" {
    type = string
    default = "20"
}
variable "target_node" {
    type = string
    default = "pve"
}
variable "clone" {
    type = string
}
variable "os_type" {
    type = string
    default = "cloud-init"
}
variable "cicustom" {
    type = string
    default = "2"
}
variable "ipre" {
    type = string
}
variable "mask" {
    type = string
}
variable "gateway" {
    type = string
}
variable "cpu" {
    type = string
    default = "host"
}
variable "sockets" {
    type = string
    default = "1"
}
variable "cores" {
    type = string
    default = "2"
}
variable "memory" {
    type = string
    default = "2048"
}
variable "agent" {
    type = string
    default = "1"
}
variable "bootdisk" {
    type = string
    default = "scsi0"
}
variable "scsihw" {
    type = string
    default = "virtio-scsi-pci"
}
variable "size" {
    type = string
}
variable "type" {
    type = string
    default = "scsi"
}
variable "storage" {
    type = string
}
variable "iothread" {
    type = string
    default = "0"
}
variable "model" {
    type = string
    default = "virtio"
}
variable "bridge" {
    type = string
    default = "vmbr0"
}
variable "dns_home_var" {
    type = string
}
variable "search_domains_home_var" {
    type = string
}
variable "dns_sst_var" {
    type = string
}
variable "search_domains_sst_var" {
    type = string
}
variable "host_home_icinga" {
    type = string
}
variable "host_sst_icinga" {
    type = string
}

