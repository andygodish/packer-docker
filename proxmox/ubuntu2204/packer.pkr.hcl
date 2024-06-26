packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_iso_pool" {
  type    = string
  default = "pve-backups:iso"
}

variable "proxmox_node" {
  type    = string
  default = ""
}

variable "proxmox_token" {
  type    = string
  default = ""
}

variable "proxmox_storage_format" {
  type    = string
  default = "qcow2"
}

variable "proxmox_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "proxmox_storage_pool_type" {
  type    = string
  default = "lvm-thin"
}

variable "proxmox_url" {
  type    = string
  default = ""
}

variable "proxmox_username" {
  type    = string
  default = ""
}

variable "template_description" {
  type    = string
  default = "Ubuntu 22.04 Template"
}

variable "template_name" {
  type    = string
  default = "Ubuntu-2204-Template"
}

variable "ubuntu_image" {
  type    = string
  default = "ubuntu-22.04.3-live-server-amd64.iso"
}

variable "version" {
  type    = string
  default = ""
}

source "proxmox-iso" "autogenerated_1" {

  proxmox_url = "${var.proxmox_url}"
  username    = "${var.proxmox_username}"
  token       = "${var.proxmox_token}"

  template_description = "Ubuntu Server Focal Image"

  cores      = "2"
  cpu_type   = "x86-64-v2-AES"
  qemu_agent = true
  disks {
    disk_size    = "32G"
    format       = "${var.proxmox_storage_format}"
    storage_pool = "${var.proxmox_storage_pool}"
    type         = "scsi"
  }
  http_directory           = "ubuntu2204/http"
  insecure_skip_tls_verify = true
  iso_file                 = "${var.proxmox_iso_pool}/${var.ubuntu_image}"
  memory                   = "4096"
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }
  node            = "${var.proxmox_node}"
  os              = "l26"
  password        = "${var.proxmox_token}"
  scsi_controller = "virtio-scsi-single"
  ssh_password    = "ubuntu"
  ssh_port        = 22
  ssh_timeout     = "20m"
  ssh_username    = "ubuntu"
  template_name   = "${var.template_name}"
  unmount_iso     = true

  cloud_init              = true
  cloud_init_storage_pool = "local"

  # PACKER Boot Commands
  boot_command = [
    "c",
    "<wait5>",
    "linux /casper/vmlinuz -- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'",
    "<enter><wait><wait>",
    "initrd /casper/initrd",
    "<enter><wait><wait>",
    "boot<enter>"
  ]
  boot_wait = "5s"
}

build {
  name    = "ubuntu-server-focal"
  sources = ["source.proxmox-iso.autogenerated_1"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo sync"
    ]
  }

  provisioner "file" {
    source      = "ubuntu2204/files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }

}
