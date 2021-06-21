#!/bin/bash

#1 - Download Last 3.2.3 Version
cd ~/Desktop
curl -O https://download.samba.org/pub/rsync/src/rsync-3.2.3.tar.gz
tar -zxvf rsync*

#2 - Patch FileFlags
curl -O https://download.samba.org/pub/rsync/src/rsync-patches-3.2.3.tar.gz
tar -zxvf /Users/adam/rsync-patches-3.2.3.tar.gz
rm rsync*.tar.gz
cd rsync-3.2.3/
patch -p1 <patches/fileflags.diff
#patch -p1 <patches/hfs-compression.diff # Broken since 3.1.3

#3 - Build
# args << "--disable-simd" if MacOS.version < :catalina
export CFLAGS="-mmacosx-version-min=10.6"
./configure --with-included-popt=yes --with-included-zlib=no --enable-ipv6 --disable-debug --disable-openssl --disable-lz4 --disable-zstd --disable-xxhash --disable-simd

make -j8
mv rsync ~/Desktop/rsync
rm -vfr ~/Desktop/rsync-*
