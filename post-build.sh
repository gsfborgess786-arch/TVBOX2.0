#!/bin/sh
# Roda depois de montar o rootfs. $1 = TARGET_DIR
set -e
T="$1"
chmod 755 "$T"/etc/init.d/S40wifi "$T"/etc/init.d/S41wifiwatch "$T"/etc/init.d/S90liveos
chmod 755 "$T"/usr/bin/liveos-*
chmod 755 "$T"/usr/lib/liveos/*.sh
chmod 755 "$T"/usr/share/liveos/cgi-bin/*
mkdir -p "$T/boot" "$T/etc/liveos"
