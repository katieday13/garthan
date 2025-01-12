#!/bin/bash
set -e -u -x -o pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update

# Setup NSD
dpkg --configure -a
apt-get install -y git net-tools nsd
# Not sure if to go with default or all non loopback addresses
default_if=$(ip route | awk '$1=="default"{print $NF}')
nonloop_if=$(ip link | awk -F': ' '/LOOPBACK/||$2==""{next}{print $2}')
(echo "server:"
# 3 would log all of it
echo "	verbosity: 2"
for d in ${nonloop_if:+$nonloop_if}; do
	echo "	ip-address: $d"
done) > /etc/nsd/nsd.conf.d/ip.conf
# Kludgery to grab github token from /vagrant
# Clone the zonefile repo
# Loop through zonefile repo adding zones with nsd-control addzone
systemctl restart nsd

apt-get install -y unbound

apt-get install -y opensmtpd-extras
