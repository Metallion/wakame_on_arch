#!/bin/bash
set -eux
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${SCRIPT_DIR}/vmspec.conf"

LXC_DIR=/var/lib/lxc
ROOTFS="${LXC_DIR}/${CONTAINER_NAME}/rootfs"

sudo lxc-create -t centos -n "${CONTAINER_NAME}"

WAKAME_REPO_URL='https://raw.githubusercontent.com/axsh/wakame-vdc/master/rpmbuild/yum_repositories/wakame-vdc-develop.repo'
sudo curl -o "${ROOTFS}"/etc/yum.repos.d/wakame-vdc-develop.repo -R "${WAKAME_REPO_URL}"

export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/centos/bin
sudo chroot "${ROOTFS}" /bin/bash -ex <<'EOS'
  usermod -U root
  echo root:centos | chpasswd

  useradd centos -G wheel
  echo centos:centos | chpasswd

  yum install -y epel-release
  yum install -y sudo

  yum install -y wakame-vdc-dcmgr-vmapp-config wakame-vdc-webui-vmapp-config
EOS

sudo rsync -av "${SCRIPT_DIR}"/rootfs/ "${ROOTFS}/"

sudo cp "${SCRIPT_DIR}/lxc_config" "${LXC_DIR}/${CONTAINER_NAME}/config"
