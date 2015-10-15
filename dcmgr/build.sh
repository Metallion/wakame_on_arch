set -eux

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LXC_DIR=/var/lib/lxc
CONTAINER_NAME=dcmgr
ROOTFS="${LXC_DIR}/${CONTAINER_NAME}/rootfs"

sudo lxc-create -t centos -n "${CONTAINER_NAME}"

WAKAME_REPO_URL='https://raw.githubusercontent.com/axsh/wakame-vdc/master/rpmbuild/yum_repositories/wakame-vdc-stable.repo'
sudo curl -o "${ROOTFS}"/etc/yum.repos.d/wakame-vdc-develop.repo -R "${WAKAME_REPO_URL}"

sudo rsync -av "${SCRIPT_DIR}"/rootfs/ "${ROOTFS}/"

export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/centos/bin
sudo chroot "${ROOTFS}" /bin/bash -ex <<'EOS'
  usermod -U root
  echo root:centos | chpasswd

  useradd centos
  echo centos:centos | chpasswd

  yum install -y epel-release
  yum install -y wakame-vdc-dcmgr-vmapp-config
EOS

sudo cp "${SCRIPT_DIR}/lxc_config" "${LXC_DIR}/${CONTAINER_NAME}/config"
