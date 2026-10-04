#!/bin/bash
# Gera os dois arquivos que o LiveOS precisa:
#   sdcard.img              -> vai no cartao SD
#   RK30xxLoader_uboot.bin  -> vai na memoria (NAND) da stick, por USB
# Rode num Linux (no Windows: dentro do WSL2/Ubuntu) com internet.
#   sudo apt update && sudo apt install -y build-essential git wget cpio unzip rsync bc file python3 \
#        libncurses-dev libssl-dev swig python3-setuptools python3-dev python3-pyelftools
set -e
cd "$(dirname "$0")"
BR_VER=2024.08.1

if [ ! -d buildroot ]; then
	wget -q "https://buildroot.org/downloads/buildroot-$BR_VER.tar.gz"
	tar xf "buildroot-$BR_VER.tar.gz"
	mv "buildroot-$BR_VER" buildroot
fi

make -C buildroot BR2_EXTERNAL="$PWD/external" liveos_rk3066_defconfig
make -C buildroot            # demora horas na primeira vez

IMGS="$PWD/buildroot/output/images"
tools/make-nand-loader.sh "$IMGS" "$PWD/saida"
cp "$IMGS/sdcard.img" saida/
echo
echo "Pronto. Arquivos em: $PWD/saida"
ls -lh saida
echo "Copie a pasta 'saida' para o Windows (ex.: cp -r saida /mnt/c/Users/SEU_USUARIO/Desktop/liveos)"
