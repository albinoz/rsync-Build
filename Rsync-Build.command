#!/bin/bash
clear
tput bold ; echo "adam | 2025-03-13" ; echo ; tput sgr0
THREADS=$(sysctl -n hw.ncpu)

#1 - Download Last Version
VERSION=$(curl -fsSL https://download.samba.org/pub/rsync/src/ \
    | grep -oE 'rsync-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz' \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
    | sort -V | tail -1)

echo "Version détectée : rsync $VERSION"

curl -O "https://download.samba.org/pub/rsync/src/rsync-${VERSION}.tar.gz"
tar -zxvf "rsync-${VERSION}.tar.gz"

#2 - Patch FileFlags
mkdir -p patches
curl -fsSL https://raw.githubusercontent.com/RsyncProject/rsync-patches/master/fileflags.diff \
    -o patches/fileflags.diff

cd "rsync-${VERSION}"

patch -p1 --ignore-whitespace --forward < ../patches/fileflags.diff || true

# Fix du hunk rejeté dans t_stub.c (preserve_acls déjà présent dans 3.4.x)
if [ -f t_stub.c.rej ]; then
    if ! grep -q 'force_change' t_stub.c; then
        sed -i '' 's/^int module_dirlen = 0;/int module_dirlen = 0;\nint force_change = 0;/' t_stub.c
        echo "force_change ajouté dans t_stub.c"
    fi
    rm -f t_stub.c.rej
fi

#3 - Build
export CFLAGS="-mmacosx-version-min=10.6"
export LDFLAGS="-mmacosx-version-min=10.6"

# ac_cv_func_utimensat=no : désactive utimensat (dispo seulement macOS 10.13+)
# sans ça le binaire crasherait sur 10.6-10.12 malgré le deployment target
./configure \
    ac_cv_func_utimensat=no \
    --with-included-popt=yes --enable-ipv6 --disable-debug \
    --disable-openssl --disable-lz4 --disable-zstd --disable-xxhash --disable-roll-simd

make -j "$THREADS"

# Move & Remove
#cd
#mv ~/rsync-*/rsync ~/Desktop/rsync
#mv ~/Desktop/rsync-* ~/.Trash/
#mv ~/rsync-* ~/.Trash/

tput bold ; echo ; echo "Time to Build" ; tput sgr0
printf '%dh:%dm:%ds\n' $((SECONDS/3600)) $((SECONDS%3600/60)) $((SECONDS%60))
