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

  yum install -y epel-release sudo

  echo '%wheel	ALL=(ALL)	ALL' >> /etc/sudoers
  sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
  sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config

  echo '
if [ -f /etc/first_boot.sh ]; then
  # We're using su here so ruby won't complain about certain environment variables not being set
  su root -c /etc/first_boot.sh
  mv /etc/first_boot.sh /etc/first_boot.sh.was_run
fi' >> /etc/rc.local

  echo "PS1='[\[\033[00;36m\]\t\[\033[00m\]] \[\e[1;31m\]\u\[\033[01;32m\]@\[\033[01;36m\]\h \[\033[01;34m\] (\w) >\[\033[00m\] '" >> /root/.bashrc

  echo "PS1='[\[\033[00;36m\]\t\[\033[00m\]] \[\033[01;32m\]\u@\[\033[01;36m\]\h \[\033[01;34m\] (\w) >\[\033[00m\] '" >> /home/centos/.bashrc

  yum install -y wakame-vdc-dcmgr-vmapp-config wakame-vdc-webui-vmapp-config
EOS

sudo rsync -av "${SCRIPT_DIR}"/rootfs/ "${ROOTFS}/"

sudo cp "${SCRIPT_DIR}/lxc_config" "${LXC_DIR}/${CONTAINER_NAME}/config"
