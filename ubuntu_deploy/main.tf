terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://192.168.68.126:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = var.pm_password
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "ubuntu_vm" {
  count       = var.vm_count
  name        = "ubuntu-test-${count.index + 1}"
  target_node = "chrislab1"
  clone       = "ubuntu-cloud" # or use template ID if needed
  vmid        = 5100 + count.index

  boot       = "order=scsi0"
  bootdisk   = "scsi0"

  agent = 1

  serial {
    id = "0"
    type = "socket"
  }

  vga {
    type = "serial0"
  }

  cores       = 2
  memory      = 2048
  scsihw      = "virtio-scsi-pci"

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  disk {
    slot     = "scsi0"
    size     = "10G"
    type     = "disk"
    storage  = "local-lvm"
  }

  disk {
  type    = "cloudinit"
  storage = "local-lvm"
  size    = "4M"
  slot    = "ide2"      # make sure it doesn’t conflict with scsi0 or other disks
}

  os_type = "cloud-init"

  ipconfig0 = "ip=dhcp"
  ciuser = "chris"
  cipassword = "1231"
  sshkeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILOuShhjGFy27SkGKjAUAZs4tYSZqnLcL/ZquvkmYuNm chris@chris-mac"


  lifecycle {
    ignore_changes = [network]
  }
}