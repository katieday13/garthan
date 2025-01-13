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
# Kludgery to get opensmtpd to look in /etc/opensmtpd/opensmtpd.conf.d/*.conf if possible
# Config overrides... in the conf.d if appropriate... otherwise rewrite file with any generated details
# Although 'maildir ~/Maildir ~/Maildir/Junk' may be sufficient
# Unclear on adding opensmtpd-filter-dkimsign, opensmtpd-filter rspamd, opensmtpd-filter-senderscore

apt-get install -y dovecot-imapd dovecot-sqlite dovecot-managesieved dovecot-solr dovecot-submissiond
# And kludgery to configure
# dovecot-fts-xapian may be better idea than solr

apt-get install -y inspircd atheme-services-contrib
