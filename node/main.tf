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
  config         = yamldecode(data.external.config.result.config)
  node_image_url = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
  node_count     = length(local.config.nodes)
}

data "external" "config" {
  program     = ["sh", "-c", "print-config-as-yaml | yq -o json | jq '{\"config\":\"\\(.)\"}'"]
  working_dir = ".."
}

resource "libvirt_domain" "node" {
  count = local.node_count

  autostart = true
  cloudinit = libvirt_cloudinit_disk.node_seed[count.index].id
  memory    = local.config.nodes[count.index].qemu.memory / 1024 / 1024
  name      = local.config.nodes[count.index].name
  running   = true
  vcpu      = local.config.nodes[count.index].qemu.vcpus

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
    hostname     = local.config.nodes[count.index].name
    network_name = "default"
  }
}

resource "libvirt_volume" "node" {
  count = local.node_count

  base_volume_id = libvirt_volume.node_base.id
  name           = "${local.config.nodes[count.index].name}.qcow2"
  pool           = libvirt_pool.node.name
  size           = local.config.nodes[count.index].qemu.disk
}

resource "libvirt_volume" "node_base" {
  format = "qcow2"
  name   = basename(local.node_image_url)
  pool   = libvirt_pool.node.name
  source = local.node_image_url
}

resource "libvirt_cloudinit_disk" "node_seed" {
  count = local.node_count

  name      = "${local.config.nodes[count.index].name}-seed.iso"
  pool      = libvirt_pool.node.name
  user_data = data.template_file.node_seed_user_data[count.index].rendered
  meta_data = data.template_file.node_seed_meta_data[count.index].rendered
}

data "template_file" "node_seed_meta_data" {
  count = local.node_count

  template = file("${path.root}/meta-data.tpl")
  vars = {
    instance_id    = local.config.nodes[count.index].name
    local_hostname = local.config.nodes[count.index].name
  }
}

data "template_file" "node_seed_user_data" {
  count = local.node_count

  template = file("${path.root}/user-data.tpl")
  vars = {
    ssh_public_key = file(format("%s.pub", pathexpand(local.config.nodes[count.index].ssh.keyPath)))
    user           = local.config.nodes[count.index].ssh.user
  }
}

resource "libvirt_pool" "node" {
  name = local.config.cluster.name
  path = "/var/lib/libvirt/images/${local.config.cluster.name}"
  type = "dir"
}
