#terraform {
#  required_providers {
#    proxmox = {
#      source = "telmate/proxmox"
#      version = "2.9.14"
#    }
#  }
#}

terraform {
    required_providers {
        proxmox = {
            source = "loeken/proxmox"
            version = "2.9.16"
        }
    }
}

provider "proxmox" {
  pm_api_url = var.pm_api_url
  pm_api_token_id = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_log_enable = true
  pm_log_file   = "/ADATA/terraform-plugin-proxmox.log"
  pm_debug      = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

# Source the Cloud Init Config file
data "template_file" "cloud_init_k8s" {
  template  = "${file("${path.module}/cloud_init.cloud_config")}"
  
  vars = {
    ssh_key = file("~/.ssh/id_rsa.pub")
    
    host_master1="10.100.100.205 master1.locdev.net master1"
    host_master2="10.100.100.206 master2.locdev.net master2"
    host_master3="10.100.100.207 master3.locdev.net master3"
    host_worker1="10.100.100.215 worker1.locdev.net worker1"
    host_worker2="10.100.100.216 worker2.locdev.net worker2"
    host_worker3="10.100.100.217 worker3.locdev.net worker3"
    
    dns_home = var.dns_home_var
    search_domains_home = var.search_domains_home_var
    
  }
}

# Create a local copy of the file, to transfer to Proxmox
resource "local_file" "cloud_init_k8s" {
  content   = data.template_file.cloud_init_k8s.rendered
  filename  = "${path.module}/user_data_cloud_init_k8s.cfg"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "cloud_init_k8s" {
  connection {
    type    = "ssh"
    user    = "root"
    private_key = file("~/.ssh/id_rsa_decrypt")
    host    = var.proxmox_ip
  }

# pve storage "snippets" !!
  provisioner "file" {
    source       = local_file.cloud_init_k8s.filename
    destination  = "/var/lib/pve/local-btrfs/snippets/cloud_init_k8s.yml"
  }
}

# Create the VM master
resource "proxmox_vm_qemu" "master" {
  ## Wait for the cloud-config file to exist

  depends_on = [
    null_resource.cloud_init_k8s
  ]
  
  count = var.count_master
  name = "master${count.index + 1}"
  vmid = "${var.vm_id_master_prefix}${count.index + 5}"
  target_node = var.proxmox_host

  # Clone from xxx-ci-x64-tmpl template
  clone = var.template_name
  os_type = "cloud-init"

  # Cloud init options
  cicustom = var.ci_custom
  ipconfig0 = "ip=${var.ip_master}${count.index + 5}/${var.ipmask},gw=${var.gateway}"
  
  cpu = "host"
  sockets  = "1"
  cores   = var.cpu_cores
  memory  = var.memory_master
  agent   = 1

  # Set the boot disk paramters
  bootdisk = "scsi0"
  scsihw       = "virtio-scsi-pci"

  disk {
    size            = "200G"
    type            = "scsi"
    storage         = var.vm_storage
    iothread        = 0
  }

  # Set the network
  network {
    model = "virtio"
    bridge = "vmbr0"
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


