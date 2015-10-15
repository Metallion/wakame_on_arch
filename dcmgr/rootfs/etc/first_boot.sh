#!/bin/bash

service mysqld start
chkconfig mysqld on

cp /opt/axsh/wakame-vdc/dcmgr/config/dcmgr.conf.example /etc/wakame-vdc/dcmgr.conf

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

  network dhcp addrange nw-demo1 192.168.4.100 192.168.4.230

  macrange add 525400 1 ffffff --uuid mr-demomacs

  network dc add public --uuid dcn-public --description "the network instances are started in"
  network forward nw-simple public

  network dc add-network-mode public securitygroup
CMDSET
