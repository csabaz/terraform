#!/usr/bin/env bash

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
    rm $3
}

export storage="local-btrfs"
export os_type="l26"
export net_bridge="vmbr0"
export memory="4096"
export cpu_type="host"
export cores="2"
export disk_hw="virtio-scsi-pci"
export disk_size="48G"

# TEMPLATE TO INSTALL: bookworm, bullseye or jammy !!!

export TEMPLATE="bookworm"

# download image
if [ "${TEMPLATE}" = "bookworm" ]
then
  export vm_id="899"
  export vm_name="bookworm-ci-x64-k8s"
  export cloud_iso="bookworm-ci-x64-k8s.qcow2"
  export ci_url="https://cloud.debian.org/images/cloud/bookworm/daily/latest/debian-12-genericcloud-amd64-daily.qcow2"
  curl -Lo ${cloud_iso} ${ci_url}
elif [ "${TEMPLATE}" = "bullseye" ]
then
  export vm_id="898"
  export vm_name="bullseye-ci-x64-k8s"
  export cloud_iso="bullseye-ci-x64-k8s.qcow2"
  export ci_url="https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
  curl -Lo ${cloud_iso} ${ci_url}
elif [ "${TEMPLATE}" = "jammy" ]
then
  export vm_id="897"
  export vm_name="jammy-ci-x64-k8s"
  export cloud_iso="jammy-ci-x64-k8s.qcow2"
  export ci_url="https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  curl -Lo ${cloud_iso} ${ci_url}
else
  echo "NO TEMPLATE SPECIFIED, BYE"
  exit 1
fi

# Install libguesetfs-tools to modify cloud image
#apt-get update
#apt-get install -y --no-install-recommends libguestfs-tools

# Add any additional packages you want installed in the template, truncate machine_id for correct ipconfig
virt-customize --install qemu-guest-agent -a ${cloud_iso}
virt-customize --run-command 'truncate -s 0 /etc/machine-id' -a ${cloud_iso}
virt-customize --run-command 'truncate -s 0 /var/lib/dbus/machine-id' -a ${cloud_iso}

create_template ${vm_id} "${vm_name}" "${cloud_iso}" 


## Debian
#Bullseye (11)
#https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2
#Bookworm (12 dailies - not yet released)
#https://cloud.debian.org/images/cloud/bookworm/daily/latest/debian-12-genericcloud-amd64-daily.qcow2

## Ubuntu
#22.04 (Jammy Jellyfish)
#https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img
