#!/bin/bash
set -eux
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${SCRIPT_DIR}/vmspec.conf"

sudo lxc-destroy -n "${CONTAINER_NAME}"

