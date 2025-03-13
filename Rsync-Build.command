#!/bin/bash                      
clear
tput bold ; echo "adam | 2025-03-13" ; echo ; tput sgr0
THREADS=$(sysctl -n hw.ncpu)

#1 - Download Last Version
curl -O https://download.samba.org/pub/rsync/src/rsync-3.4.1.tar.gz
tar -zxvf rsync-*.tar.gz

#2 - Patch FileFlags
curl -O https://download.samba.org/pub/rsync/src/rsync-patches-3.4.1.tar.gz
tar -zxvf rsync-patches-*.tar.gz

cd rsync-3.*/
patch -p1 <patches/fileflags.diff

#3 - Build
export CFLAGS="-mmacosx-version-min=10.6"
export LDFLAGS="-mmacosx-version-min=10.6"
./configure --with-included-popt=yes  --enable-ipv6 --disable-debug \
--disable-openssl --disable-lz4 --disable-zstd --disable-xxhash --disable-roll-simd

make -j "$THREADS"

# Move & Remove
cd
mv ~/rsync-*/rsync ~/Desktop/rsync
mv ~/Desktop/rsync-* ~/.Trash/
mv ~/rsync-* ~/.Trash/

tput bold ; echo ; echo "Time to Build" ; tput sgr0
printf '%dh:%dm:%ds\n' $((SECONDS/3600)) $((SECONDS%3600/60)) $((SECONDS%60))
