# k0s Hands-on

🎊Happy New Year 2023! My learning project during the winter vacation.

This is fully containerized evaluation environment to build [Kubernetes](https://kubernetes.io/) multi node cluster with [k0s](https://k0sproject.io/). It consists of two containers, one for work and one for the hypervisor. the `dev` container is built from the [Docker official image of Alpine Linux](https://hub.docker.com/_/alpine/) and has the essential tools installed (similar but unrelated to [Development Containers](https://containers.dev/)). On the other hand, the `libvirt` container is built from the [Docker official image of Rocky Linux](https://hub.docker.com/_/rockylinux/), with [Libvirt](https://libvirt.org/) daemon running on [SystemD](https://systemd.io/). **So you don't have to manually prepare a virtualization infrastructure or virtual machines.** Instead, [Terraform](https://www.terraform.io/) and [Terraform provider for libvirt](https://github.com/dmacvicar/terraform-provider-libvirt) make all the steps automated and reproducible.

The virtual machines use [Debian official cloud Image](https://cloud.debian.org/images/cloud/).

There are many things to be improved, but since the vacation ends today, I'm releasing for now.

## Prerequisites

- Linux (KVM enabled)
- GNU Make
- Docker Compose

## Getting started

### Setup

```sh
$ make dev # create and enter `dev` container
...
dev:/mnt$ make up # create the virtual machines and the cluster
...
NAME     STATUS   ROLES    AGE   VERSION
node-2   Ready    <none>   57s   v1.25.4+k0s
node-3   Ready    <none>   57s   v1.25.4+k0s
```

### Working in `dev` container

```sh
dev:/mnt$ virsh list # manage the virtual machines
 Id   Name     State
------------------------
 1    node-1   running
 2    node-2   running
 3    node-3   running
```

```sh
dev:/mnt$ ssh node-1 # enter the virtual machine
...
node@node-1:~$
```

```sh
dev:/mnt$ kubectl get node # manage the cluster
NAME     STATUS   ROLES    AGE   VERSION
node-2   Ready    <none>   57s   v1.25.4+k0s
node-3   Ready    <none>   57s   v1.25.4+k0s
```

### Teardown

```sh
dev:/mnt$ make down # stop the virtual machines and the cluster
dev:/mnt$ make clean # delete the virtual machines and the cluster
dev:/mnt$ exit # exit `dev` container
$ make dev/down # stop `dev` container
$ make dev/clean # delete all files and volumes
```

## Reference

- [k0sctl](https://github.com/k0sproject/k0sctl)
- [Libvirt Daemons](https://libvirt.org/daemons.html)
- [Libvirt NSS module](https://libvirt.org/nss.html)
- [Container Interface](https://systemd.io/CONTAINER_INTERFACE/)
