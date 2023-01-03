#!/bin/sh

set -eu

function inplace_replace() {
    local exp="${1}"
    local file="${2}"
    local out="$(sed -r "${exp}" "${file}")" # `-i` causes permission denied (temporary file can not be created in `/etc`).
    echo "${out}" > "${file}"
}

inplace_replace "s|^(dev):([^:]*):([^:]*)|\\1:\\2:${DEV_GID}|" /etc/group
inplace_replace "s|^(dev):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)|\\1:\\2:${DEV_UID}:${DEV_GID}:\\5:${DEV_HOME}|" /etc/passwd
sudo chmod o-w /etc/group /etc/passwd
