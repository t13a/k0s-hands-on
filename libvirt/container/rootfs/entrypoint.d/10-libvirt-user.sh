#!/bin/sh

set -eu

id libvirt > /dev/null || useradd -g libvirt -m libvirt
