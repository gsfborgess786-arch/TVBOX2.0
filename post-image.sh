#!/bin/sh
# Monta o sdcard.img. BINARIES_DIR vem do ambiente do Buildroot.
set -e
BOARD_DIR="$(dirname "$0")"
mkdir -p "$BINARIES_DIR/extlinux"
cp "$BOARD_DIR/extlinux.conf" "$BINARIES_DIR/extlinux/extlinux.conf"
cp "$BOARD_DIR/liveos-wifi.txt" "$BINARIES_DIR/liveos-wifi.txt"
exec support/scripts/genimage.sh -c "$BOARD_DIR/genimage.cfg"
