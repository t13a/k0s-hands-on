#!/bin/sh

set -eu

# XXX: do not use in production environment
systemctl enable virtproxyd-tcp.socket
