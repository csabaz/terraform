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
    aduser = var.aduser
    ssh_key = file("~/.ssh/id_rsa.pub")
    host_icinga = var.host_icinga

    dns = var.dns
    search_domains = var.search_domains

    mysql_root_pass_new = var.mysql_root_pass_new
    mysql_icinga_ido_pass = var.mysql_icinga_ido_pass
    mysql_icinga_web_pass = var.mysql_icinga_web_pass
    mysql_icinga_director_pass = var.mysql_icinga_director_pass
    mysql_root_pass_current = var.mysql_root_pass_current
    icinga_dist = var.icinga_dist
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
    destination  = "/var/lib/pve/btrfs-1tb/snippets/cloud_init_icinga.yml"
  }
}

# Create the VM master
resource "proxmox_vm_qemu" "icinga" {
  ## Wait for the cloud-config file to exist

  depends_on = [
    null_resource.cloud_init_icinga
  ]
  
  count       = "1"
  name        = var.name
  vmid        = "${var.vm_id_prefix}${count.index + 4}"
  target_node = var.target_node

  # Clone from xxx-ci-x64-icinga template
  clone       = var.clone
  os_type     = var.os_type
  cicustom    = var.cicustom
  ipconfig0   = "ip=${var.ipre}${count.index + 4}/${var.mask},gw=${var.gateway}"
  
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

