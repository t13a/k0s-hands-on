FROM rockylinux:9

RUN dnf update -y \
    && dnf install -y \
    augeas \
    libvirt \
    libvirt-nss \
    openssh-server \
    qemu-kvm \
    systemd \
    && dnf clean all

# Debugging
RUN dnf install -y \
    net-tools \
    procps-ng \
    psmisc \
    && dnf clean all

RUN systemctl set-default multi-user.target \
    && systemctl mask libvirtd.service libvirtd{,-admin,-ro,-tcp,-tls}.socket

COPY rootfs /

ENV container oci

STOPSIGNAL SIGRTMIN+3

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/sbin/init"]
