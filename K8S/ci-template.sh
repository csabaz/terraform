#!/usr/bin/env bash
# usage:
# ssh root@proxmox_host < 01-ci-template.sh
# Install on host libguesetfs-tools to modify cloud image
apt-get update
if [ $(dpkg-query -W -f='${Status}' libguesetfs-tools 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
   apt-get install -y --no-install-recommends libguestfs-tools
fi
# vm specifications
export storage="local-btrfs"
export os_type="l26"
export net_bridge="vmbr0"
export memory="4096"
export cpu_type="host"
export cores="3"
export disk_hw="virtio-scsi-pci"
export disk_size="192G"

# template to install: bookworm or jammy
export template="bookworm"

# args: "vm_id" "vm_name" "file name in the current directory"
function create_template() {
    echo "Creating template $2 ($1)"
    
    #Feel free to change any of these to your liking
    qm create $1 --name $2 --ostype "${os_type}" --net0 virtio,bridge="${net_bridge}" --memory "${memory}" --cores "${cores}" --cpu ${cpu_type}
    
    #Set display to serial
    qm set $1 --serial0 socket --vga serial0
    
    #Set boot device to new file
    qm set $1 --scsi0 ${storage}:0,import-from="$(pwd)/$3",discard=on 1> /dev/null
    
    #Set scsi hardware as default boot disk using virtio scsi single
    qm set $1 --boot order=scsi0 --scsihw "${disk_hw}"
    
    #Enable Qemu guest agent in case the guest has it available
    qm set $1 --agent enabled=1,fstrim_cloned_disks=1

    # Allow hotplugging of network, USB and disks
    qm set $1 -hotplug disk,network,usb
    
    #Add cloud-init device
    qm set $1 --ide2 ${storage}:cloudinit
    
    #Resize the disk
    qm disk resize $1 scsi0 ${disk_size}
    
    #Make it a template
    qm template $1
        
    #Remove file when done
    #rm $3
}

download_image() {
    echo "download image $1"
    if [ "${1}" = "jammy" ]
    then
      export vm_id="921"
      export vm_name="${1}-ci-x64-k8s"
      export cloud_iso="${1}-ci-x64-k8s.qcow2"
      export ci_url="https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
      test -f "${cloud_iso}" && echo "cloud image is already downloaded, so I use it" || curl -Lo ${cloud_iso} ${ci_url}
    #Ubuntu 22.04 (Jammy Jellyfish)
    else    
      export vm_id="911"
      export vm_name="${1}-ci-x64-k8s"
      export cloud_iso="${1}-ci-x64-k8s.qcow2"
      export ci_url="https://cloud.debian.org/images/cloud/bookworm/daily/latest/debian-12-genericcloud-amd64-daily.qcow2"
      if [ -f "${cloud_iso}" ]; then
          echo "cloud image is already downloaded, so I use it"
      else
          curl -Lo ${cloud_iso} ${ci_url}
          # Add any additional packages you want installed in the template, truncate machine_id for correct ipconfig
          virt-customize --install qemu-guest-agent -a ${cloud_iso}
          virt-customize --run-command 'truncate -s 0 /etc/machine-id' -a ${cloud_iso}
          virt-customize --run-command 'truncate -s 0 /var/lib/dbus/machine-id' -a ${cloud_iso}
      fi
    fi
}

# download image
download_image "$template"

# create proxmox template
create_template "${vm_id}" "${vm_name}" "${cloud_iso}" 

