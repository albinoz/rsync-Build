#!/bin/bash
# adam - 22/06/22

#0 - Purge
rm -vfr rsync-*

#1 - Download Last 3.2.3 Version
curl -O https://download.samba.org/pub/rsync/src/rsync-3.2.3.tar.gz
tar -zxvf rsync*

#2 - Patch FileFlags
curl -O https://download.samba.org/pub/rsync/src/rsync-patches-3.2.3.tar.gz
tar -zxvf ~/Desktop/rsync-patches-3.2.3.tar.gz
rm rsync*.tar.gz
cd rsync-3.2.3/
patch -p1 <patches/fileflags.diff
#patch -p1 <patches/hfs-compression.diff # Broken since 3.1.3

#3 - Build
# --disable-simd if macOS 10.15+ Build
export CFLAGS="-mmacosx-version-min=10.6"
./configure --with-included-popt=yes --with-included-zlib=no --enable-ipv6 \
--disable-debug --disable-openssl --disable-lz4 --disable-zstd --disable-xxhash \
--disable-simd

make -j8
mv rsync ~/Desktop/rsync
rm -vfr rsync-*
