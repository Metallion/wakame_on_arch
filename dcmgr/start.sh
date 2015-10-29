#!/bin/bash
set -eux
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${SCRIPT_DIR}/vmspec.conf"

CONSOLE_LOG=${SCRIPT_DIR}/console.log
LXC_LOG=${SCRIPT_DIR}/lxc.log

sudo lxc-start -n "${CONTAINER_NAME}" -L "${CONSOLE_LOG}" --logfile "${LXC_LOG}"
