FROM alpine:edge AS builder

RUN apk --no-cache add \
    curl

RUN curl -sSL https://github.com/cue-lang/cue/releases/download/v0.4.3/cue_v0.4.3_linux_amd64.tar.gz | tar xzf - cue \
    && mv cue /usr/local/bin

FROM alpine:edge

COPY --from=builder /usr/local/bin /usr/local/bin

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
    terraform \
    tini \
    virt-install \
    yq

RUN adduser -s /bin/bash -DH dev \
    && chmod o+w /etc /etc/group /etc/passwd

COPY rootfs /

WORKDIR /mnt

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/sbin/tini", "sleep", "infinite"]
