FROM alpine:edge

RUN echo https://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories

RUN apk --no-cache add \
    augeas \
    bash \
    bash-completion \
    cdrkit \
    curl \
    git \
    git-bash-completion \
    jq \
    k0sctl \
    k0sctl-bash-completion \
    kubectl \
    kubectl-bash-completion \
    libvirt-bash-completion \
    libvirt-client \
    make \
    openssh-client-default \
    sudo \
    tini \
    virt-install \
    yq

RUN adduser -s /bin/bash -DH dev \
    && chmod o+w /etc /etc/group /etc/passwd

COPY rootfs /

WORKDIR /mnt

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/sbin/tini", "sleep", "infinite"]
