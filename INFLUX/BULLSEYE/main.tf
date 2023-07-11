terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.pm_api_url
  pm_api_token_id = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  #pm_log_enable = true
  #pm_log_file   = "/ADATA/terraform-plugin-proxmox.log"
  #pm_debug      = true
  #pm_log_levels = {
  #  _default    = "debug"
  #  _capturelog = ""
  #}
}

# Source the Cloud Init Config file
data "template_file" "cloud_init_icinga" {
  template  = "${file("${path.module}/cloud_init.cloud_config")}"
  
  vars = {
    ssh_key = file("~/.ssh/id_rsa.pub")
    host_home_influx=var.host_home_influx
    host_sst_influx=var.host_sst_influx    

    dns_home = var.dns_home_var
    search_domains_home = var.search_domains_home_var

    dns_sst = var.dns_sst_var
    search_domains_sst = var.search_domains_sst_var
    
  }
}

# Create a local copy of the file, to transfer to Proxmox
resource "local_file" "cloud_init_icinga" {
  content   = data.template_file.cloud_init_icinga.rendered
  filename  = "${path.module}/cloud_init.cloud_config_generated.cfg"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "cloud_init_icinga" {
  connection {
    type    = "ssh"
    user    = "root"
    private_key = file("~/.ssh/id_rsa_decrypt")
    host    = var.proxmox_ip
  }

# pve storage "snippets" !!
  provisioner "file" {
    source       = local_file.cloud_init_icinga.filename
    destination  = "/var/lib/pve/local-btrfs/snippets/cloud_init_icinga.yml"
  }
}

# Create the VM master
resource "proxmox_vm_qemu" "influx" {
  ## Wait for the cloud-config file to exist

  depends_on = [
    null_resource.cloud_init_icinga
  ]
  
  count       = "1"
  name        = var.name
  vmid        = "${var.vm_id_prefix}${count.index + 3}"
  target_node = var.target_node

  # Clone from xxx-ci-x64-icinga template
  clone       = "${var.template}${var.clonetag}${var.tmpl}"
  os_type     = var.os_type
  cicustom    = var.cicustom
  ipconfig0   = "ip=${var.ipre}${count.index + 3}/${var.mask},gw=${var.gateway}"
  
  cpu         = var.cpu
  sockets     = var.sockets
  cores       = var.cores
  memory      = var.memory
  agent       = var.agent

  # Set the boot disk paramters
  bootdisk    = var.bootdisk
  scsihw      = var.scsihw

  disk {
    size      = var.size
    type      = var.type
    storage   = var.storage
    iothread  = var.iothread
  }

  # Set the network
  network {
    model     = var.model
    bridge    = var.bridge
  }

  # Ignore changes to the network
  ## MAC address is generated on every apply, causing
  ## TF to think this needs to be rebuilt on every apply
  lifecycle {
     ignore_changes = [
       network
     ]
  }
}

