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
  config         = yamldecode(file(pathexpand("../k0sctl.override.yaml")))
  node_image_url = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
  node_count     = length(local.config.spec.hosts)
}

resource "libvirt_domain" "node" {
  count = local.node_count

  autostart = true
  cloudinit = libvirt_cloudinit_disk.node_seed[count.index].id
  memory    = 1024
  name      = local.config.spec.hosts[count.index].ssh.address
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
    volume_id = libvirt_volume.node[count.index].id
  }

  graphics {
    type = "vnc"
  }

  network_interface {
    hostname     = local.config.spec.hosts[count.index].ssh.address
    network_name = "default"
  }
}

resource "libvirt_volume" "node" {
  count = local.node_count

  base_volume_id = libvirt_volume.node_base.id
  name           = "${local.config.spec.hosts[count.index].ssh.address}.qcow2"
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
  count = local.node_count

  name      = "${local.config.spec.hosts[count.index].ssh.address}-seed.iso"
  pool      = libvirt_pool.node.name
  user_data = data.template_file.node_seed_user_data[count.index].rendered
  meta_data = data.template_file.node_seed_meta_data[count.index].rendered
}

data "template_file" "node_seed_meta_data" {
  count = local.node_count

  template = file("${path.root}/meta-data.tpl")
  vars = {
    instance_id    = local.config.spec.hosts[count.index].ssh.address
    local_hostname = local.config.spec.hosts[count.index].ssh.address
  }
}

data "template_file" "node_seed_user_data" {
  count = local.node_count

  template = file("${path.root}/user-data.tpl")
  vars = {
    ssh_public_key = file(format("%s.pub", pathexpand(local.config.spec.hosts[count.index].ssh.keyPath)))
    user           = local.config.spec.hosts[count.index].ssh.user
  }
}

resource "libvirt_pool" "node" {
  name = local.config.metadata.name
  path = "/var/lib/libvirt/images/${local.config.metadata.name}"
  type = "dir"
}
