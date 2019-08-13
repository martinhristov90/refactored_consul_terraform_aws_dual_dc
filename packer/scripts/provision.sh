#!/bin/usr/env bash

# Installing needed utilites
apt-get clean
apt-get update

apt-get install -y curl vim unzip jq socat

apt-get autoremove -y
apt-get clean