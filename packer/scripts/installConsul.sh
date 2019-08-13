#!/bin/usr/env bash

set -x

P=consul

VERSION=$(curl -sL https://releases.hashicorp.com/${P}/index.json | jq -r '.versions[].version' | sort -V | egrep -v 'ent|beta|rc|alpha' | tail -n1)
#VERSION=""
# arch
if [[ "`uname -m`" =~ "arm" ]]; then
  ARCH=arm
else
  ARCH=amd64
fi
wget -q -O /tmp/${P}.zip https://releases.hashicorp.com/${P}/${VERSION}/${P}_${VERSION}_linux_${ARCH}.zip
unzip -o -d /usr/local/bin /tmp/${P}.zip
rm /tmp/${P}.zip

echo "Installing Consul... "

# Installing autocomplete.
consul -autocomplete-install
complete -C /usr/local/bin/consul consul

# Adding consul user.
# /opt/consul is going to be used as datadir for Consul.
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul
sudo chown --recursive consul:consul /opt/consul

# Setting consul config and home dir
sudo mkdir --parents /etc/consul.d
sudo chown --recursive consul:consul /etc/consul.d


# Integrating Consul as Systemd service.
# Service is not enabled by default, going to be enabled in Vagrant.
sudo touch /etc/systemd/system/consul.service

cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/usr/local/bin/consul reload
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
