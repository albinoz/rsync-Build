#!/bin/bash
clear
tput bold ; echo "adam | 2022-12-22" ; echo ; tput sgr0
THREADS=$(sysctl -n hw.ncpu)

#_ Made RamDisk
if diskutil list | grep RamDisk ; then
echo RamDisk Exist
else
# Minimum RamDisk
tput bold ; echo ; echo '💾 ' Made RamDisk ; tput sgr0
diskutil erasevolume HFS+ 'RamDisk' $(hdiutil attach -nomount ram://50000)
fi

#_ CPU & PATHS & ERROR
THREADS=$(sysctl -n hw.ncpu)
TARGET="/Volumes/RamDisk/sw"
CMPL="/Volumes/RamDisk/compile"
export PATH="${TARGET}"/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/include:/usr/local/opt:/usr/local/Cellar:/usr/local/lib:/usr/local/share:/usr/local/etc
mdutil -i off /Volumes/RamDisk

#_ Make RamDisk Directories
mkdir ${TARGET}
mkdir ${CMPL}
rm -fr /Volumes/RamDisk/compile/*

#1 - Download Last Version
cd ${CMPL} ; sleep 1
curl -O https://download.samba.org/pub/rsync/src/rsync-3.2.7.tar.gz
tar -zxvf rsync-*.tar.gz

#2 - Patch FileFlags
curl -O https://download.samba.org/pub/rsync/src/rsync-patches-3.2.7.tar.gz
tar -zxvf rsync-patches-*.tar.gz

cd rsync-3.*/
patch -p1 <patches/fileflags.diff
#patch -p1 <patches/hfs-compression.diff # Broken since 3.1.3

#3 - Build
# --disable-simd if macOS 10.15+ Build
cd ${CMPL} ; sleep 1
cd rsync-3.*/
export CFLAGS="-mmacosx-version-min=10.6"
./configure  --disable-debug --disable-openssl --disable-lz4 --disable-zstd --disable-xxhash --with-included-popt=no --with-included-zlib=no --enable-ipv6

make -j "$THREADS"
mv rsync ~/Desktop/rsync
#rm -vfr ~/Desktop/rsync-*

tput bold ; echo ; echo "Time to Build" ; tput sgr0
printf '%dh:%dm:%ds\n' $((SECONDS/3600)) $((SECONDS%3600/60)) $((SECONDS%60))
