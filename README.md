# k0s Hands-on

🎊Happy New Year 2023! My learning project during the winter vacation.

This is fully containerized evaluation environment to build [Kubernetes](https://kubernetes.io/) single node cluster with [k0s](https://k0sproject.io/). It consists of two containers, one for work and one for the hypervisor. the `dev` container is built from the [Docker official image of Alpine Linux](https://hub.docker.com/_/alpine/) and has the essential tools installed (similar but unrelated to [Development Containers](https://containers.dev/)). On the other hand, the `libvirt` container is built from the [Docker official image of Rocky Linux](https://hub.docker.com/_/rockylinux/), with [Libvirt](https://libvirt.org/) daemon running on [SystemD](https://systemd.io/). **So you don't have to manually prepare a virtualization infrastructure or a virtual machine.** Instead, a few Makefiles and shell scripts make all the steps automated and reproducible.

The virtual machine uses [Debian official cloud Image](https://cloud.debian.org/images/cloud/).

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
dev:/mnt$ make up # create the virtual machine and the cluster
...
NAME     STATUS   ROLES           AGE   VERSION
debian   Ready    control-plane   41s   v1.25.4+k0s
```

### Working in `dev` container

```sh
dev:/mnt$ virsh list # manage the virtual machine
 Id   Name     State
------------------------
 1    debian   running
```

```sh
dev:/mnt$ ssh debian # enter the virtual machine
...
debian@debian:~$
```

```sh
dev:/mnt$ kubectl get node # manage the cluster
NAME     STATUS   ROLES           AGE   VERSION
debian   Ready    control-plane   51s   v1.25.4+k0s
```

### Teardown

```sh
dev:/mnt$ make down # stop the virtual machine and the cluster
dev:/mnt$ make clean # delete the virtual machine and the cluster
dev:/mnt$ exit # exit `dev` container
$ make dev/down # stop `dev` container
$ make dev/clean # delete all files and volumes
```

## Reference

- [k0sctl](https://github.com/k0sproject/k0sctl)
- [Libvirt Daemons](https://libvirt.org/daemons.html)
- [Libvirt NSS module](https://libvirt.org/nss.html)
- [Container Interface](https://systemd.io/CONTAINER_INTERFACE/)
