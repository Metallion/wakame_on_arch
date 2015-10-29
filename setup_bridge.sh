#!/bin/bash
set -eux

sudo brctl addbr lxcbr0
sudo ip link set lxcbr0 up
sudo ip addr add 192.168.4.1/24 dev lxcbr0
