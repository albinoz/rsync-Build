#!/bin/bash
clear
tput bold ; echo "adam | 2022-06-23" ; echo ; tput sgr0
THREADS=$(sysctl -n hw.ncpu)

#1 - Download Last Version
curl -O https://download.samba.org/pub/rsync/src/rsync-3.2.4.tar.gz
tar -zxvf rsync-*.tar.gz

#2 - Patch FileFlags
curl -O https://download.samba.org/pub/rsync/src/rsync-patches-3.2.4.tar.gz
tar -zxvf rsync-patches-*.tar.gz

cd rsync-3.*/
patch -p1 <patches/fileflags.diff
#patch -p1 <patches/hfs-compression.diff # Broken since 3.1.3

#3 - Build
# --disable-simd if macOS 10.15+ Build
export CFLAGS="-mmacosx-version-min=10.6"
./configure --with-included-popt=yes --with-included-zlib=no --enable-ipv6 \
--disable-debug --disable-openssl --disable-lz4 --disable-zstd --disable-xxhash \
--disable-simd

make -j "$THREADS"
mv rsync ~/Desktop/rsync
rm -vfr ~/rsync-*

tput bold ; echo ; echo "Time to Build" ; tput sgr0
printf '%dh:%dm:%ds\n' $((SECONDS/3600)) $((SECONDS%3600/60)) $((SECONDS%60))
