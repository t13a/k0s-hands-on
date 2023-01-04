terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

provider "libvirt" {
}

locals {
  node_name      = "debian"
  node_image_url = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
}

resource "libvirt_domain" "node" {
  autostart = true
  cloudinit = libvirt_cloudinit_disk.node_seed.id
  memory    = 1024
  name      = local.node_name
  running   = true
  vcpu      = 1

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_port = "1"
    target_type = "virtio"
  }

  disk {
    volume_id = libvirt_volume.node.id
  }

  graphics {
    type = "vnc"
  }

  network_interface {
    network_name = "default"
  }
}

resource "libvirt_volume" "node" {
  base_volume_id = libvirt_volume.node_base.id
  name           = "${local.node_name}.qcow2"
  pool           = libvirt_pool.node.name
  size           = 16 * 1024 * 1024 * 1024
}

resource "libvirt_volume" "node_base" {
  format = "qcow2"
  name   = basename(local.node_image_url)
  pool   = libvirt_pool.node.name
  source = local.node_image_url
}

resource "libvirt_cloudinit_disk" "node_seed" {
  name      = "${local.node_name}-seed.iso"
  pool      = libvirt_pool.node.name
  user_data = data.template_file.node_seed_user_data.rendered
}

data "template_file" "node_seed_user_data" {
  template = file("${path.root}/user-data.tpl")
  vars = {
    ssh_public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
  }
}

resource "libvirt_pool" "node" {
  name = local.node_name
  path = "/var/lib/libvirt/images/${local.node_name}"
  type = "dir"
}
