#!/bin/usr/env bash

set -x

P=consul-template
echo "Installing Consul-template... "

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