#!/bin/bash
# Gera o carregador da NAND (RK30xxLoader_uboot.bin) a partir do TPL/SPL do U-Boot.
# Segue a doc do U-Boot (doc/board/rockchip/rockchip.rst, secao "RK3066 ... on NAND").
# Uso: tools/make-nand-loader.sh <pasta com u-boot-tpl.bin e u-boot-spl.bin> <pasta de saida>
set -e
IMG="$1"; OUT="$2"
[ -f "$IMG/u-boot-tpl.bin" ] && [ -f "$IMG/u-boot-spl.bin" ] || { echo "faltam u-boot-tpl.bin/u-boot-spl.bin em $IMG"; exit 1; }
W=$(mktemp -d); cd "$W"
git clone --depth 1 https://github.com/rockchip-linux/rkbin
DDR=$(find rkbin -name '30_LPDDR2_300MHz_DD.bin' | head -n1)
USB=$(find rkbin -name 'rk30usbplug.bin' | head -n1)
[ -n "$DDR" ] && [ -n "$USB" ] || { echo "rkbin nao tem 30_LPDDR2_300MHz_DD.bin / rk30usbplug.bin (o repositorio mudou?)"; exit 1; }
BM=$(find rkbin -name boot_merger -type f | head -n1)
[ -n "$BM" ] || { echo "boot_merger nao encontrado no rkbin"; exit 1; }
chmod +x "$BM"
printf "RK30" > tplspl.bin
cat "$IMG/u-boot-tpl.bin" >> tplspl.bin
cp "$IMG/u-boot-spl.bin" u-boot-spl.bin
truncate -s %2048 tplspl.bin
truncate -s %2048 u-boot-spl.bin
cat > config-flash.ini <<INI
[CHIP_NAME]
NAME=RK30
[VERSION]
MAJOR=2
MINOR=21
[CODE471_OPTION]
NUM=1
Path1=$DDR
[CODE472_OPTION]
NUM=1
Path1=$USB
[LOADER_OPTION]
NUM=2
LOADER1=FlashData
LOADER2=FlashBoot
FlashData=tplspl.bin
FlashBoot=u-boot-spl.bin
[OUTPUT]
PATH=RK30xxLoader_uboot.bin
INI
"./$BM" --verbose config-flash.ini
mkdir -p "$OUT"; cp RK30xxLoader_uboot.bin "$OUT/"
echo "OK: $OUT/RK30xxLoader_uboot.bin"
