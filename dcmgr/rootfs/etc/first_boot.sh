#!/bin/bash
set -eux

service mysqld start
chkconfig mysqld on

cp /opt/axsh/wakame-vdc/dcmgr/config/dcmgr.conf.example /etc/wakame-vdc/dcmgr.conf
cp /opt/axsh/wakame-vdc/frontend/dcmgr_gui/config/database.yml.example /etc/wakame-vdc/dcmgr_gui/database.yml
cp /opt/axsh/wakame-vdc/frontend/dcmgr_gui/config/dcmgr_gui.yml.example /etc/wakame-vdc/dcmgr_gui/dcmgr_gui.yml
cp /opt/axsh/wakame-vdc/frontend/dcmgr_gui/config/instance_spec.yml.example /etc/wakame-vdc/dcmgr_gui/instance_spec.yml
cp /opt/axsh/wakame-vdc/frontend/dcmgr_gui/config/load_balancer_spec.yml.example /etc/wakame-vdc/dcmgr_gui/load_balancer_spec.yml

mysqladmin -uroot create wakame_dcmgr

cd /opt/axsh/wakame-vdc/dcmgr
/opt/axsh/wakame-vdc/ruby/bin/rake db:up

grep -v '\s*#' <<CMDSET | /opt/axsh/wakame-vdc/dcmgr/bin/vdc-manage -e
  network add \
    --uuid nw-simple \
    --ipv4-network 192.168.4.0 \
    --prefix 24 \
    --dns 8.8.8.8 \
    --account-id a-shpoolxx \
    --display-name "simple network"

  network dhcp addrange nw-simple 192.168.4.100 192.168.4.230

  macrange add 525400 1 ffffff --uuid mr-demomacs

  network dc add public --uuid dcn-public --description "the network instances are started in"
  network forward nw-simple public

  network dc add-network-mode public securitygroup
CMDSET

mysqladmin -uroot create wakame_dcmgr_gui
cd /opt/axsh/wakame-vdc/frontend/dcmgr_gui/
/opt/axsh/wakame-vdc/ruby/bin/rake db:init

/opt/axsh/wakame-vdc/frontend/dcmgr_gui/bin/gui-manage -e <<CMDSET
  account add --name default --uuid a-shpoolxx
  user add --name "demo user" --uuid u-demo --password demo --login-id demo
  user associate u-demo --account-ids a-shpoolxx
CMDSET

sed -i 's/#RUN=yes/RUN=yes/g' /etc/default/vdc-collector
sed -i 's/#RUN=yes/RUN=yes/g' /etc/default/vdc-dcmgr
sed -i 's/#RUN=yes/RUN=yes/g' /etc/default/vdc-webui

service rabbitmq-server start
chkconfig rabbitmq-server on

initctl start vdc-collector
initctl start vdc-dcmgr
initctl start vdc-webui
