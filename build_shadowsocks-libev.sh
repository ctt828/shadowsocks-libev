#!/bin/bash

set -ex

# https://www.pcre.org/
PCRE_VER=8.44
PCRE_FILE="https://ftp.pcre.org/pub/pcre/pcre-$PCRE_VER.tar.gz"

# https://tls.mbed.org/download-archive 
MBEDTLS_VER=2.6.0
MBEDTLS_FILE="https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz"

# https://doc.libsodium.org/
LIBSODIUM_VER=1.0.18
LIBSODIUM_FILE="https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VER.tar.gz"

# http://software.schmorp.de/pkg/libev.html
LIBEV_VER=4.33
LIBEV_FILE="http://dist.schmorp.de/libev/libev-$LIBEV_VER.tar.gz"

# https://c-ares.haxx.se/
LIBC_ARES_VER=1.16.1
LIBC_ARES_FILE="https://c-ares.haxx.se/download/c-ares-$LIBC_ARES_VER.tar.gz"

SHADOWSOCKS_LIBEV_VER=master
#SHADOWSOCKS_LIBEV_VER=v3.3.5
SHADOWSOCKS_LIBEV_FILE="https://github.com/shadowsocks/shadowsocks-libev.git"

SIMPLE_OBFS_VER=master
#SIMPLE_OBFS_VER=v0.0.5
SIMPLE_OBFS_FILE="https://github.com/shadowsocks/simple-obfs.git"

#host=arm-linux-gnueabihf
build=$(pwd)/build
out=$(pwd)/out

mkdir -p $build
pushd $build

# Build PCRE
wget $PCRE_FILE
tar xvf pcre-$PCRE_VER.tar.gz
pushd pcre-$PCRE_VER
./configure --prefix=$out/pcre --host=$host --enable-jit --enable-utf8 --enable-unicode-properties --disable-shared
make -j$(getconf _NPROCESSORS_ONLN) && make install
popd

# Build Mbed TLS
wget $MBEDTLS_FILE
tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
pushd mbedtls-$MBEDTLS_VER
prefix_reg=$(echo $out | sed "s/\//\\\\\//g")
sed -i "s/DESTDIR=\/usr\/local/DESTDIR=$prefix_reg\/mbedtls/g" Makefile
[ -z $host ] && make install -j$(getconf _NPROCESSORS_ONLN) || CC=$host-gcc AR=$host-ar LD=$host-ld make install -j$(getconf _NPROCESSORS_ONLN)
popd

# Build libsodium
wget $LIBSODIUM_FILE
tar xvf libsodium-$LIBSODIUM_VER.tar.gz
pushd libsodium-$LIBSODIUM_VER
./configure --prefix=$out/libsodium --host=$host --disable-shared
make -j$(getconf _NPROCESSORS_ONLN) && make install
popd

# Build libev
wget $LIBEV_FILE
tar xvf libev-$LIBEV_VER.tar.gz
pushd libev-$LIBEV_VER
./configure --prefix=$out/libev --host=$host --disable-shared
make -j$(getconf _NPROCESSORS_ONLN) && make install
popd

# Build c-ares
wget $LIBC_ARES_FILE
tar xvf c-ares-$LIBC_ARES_VER.tar.gz
pushd c-ares-$LIBC_ARES_VER
./configure --prefix=$out/libc-ares --host=$host --disable-shared
make -j$(getconf _NPROCESSORS_ONLN) && make install
popd

# Build shadowsocks-libev
git clone --branch $SHADOWSOCKS_LIBEV_VER --single-branch --depth 1 $SHADOWSOCKS_LIBEV_FILE
pushd shadowsocks-libev
git submodule update --init --recursive
./autogen.sh
LIBS="-lpthread -lm" ./configure --prefix=$out/shadowsocks-libev --host=$host --disable-documentation --with-pcre=$out/pcre --with-mbedtls=$out/mbedtls --with-sodium=$out/libsodium --with-cares=$out/libc-ares --with-ev=$out/libev
make -j$(getconf _NPROCESSORS_ONLN) && make install
popd

# Build simple-obfs
git clone --branch $SIMPLE_OBFS_VER --single-branch --depth 1 $SIMPLE_OBFS_FILE
pushd simple-obfs
git submodule update --init --recursive
./autogen.sh
LIBS="-lm" LDFLAGS="-L$out/libev/lib" CFLAGS="-I$out/libev/include" ./configure --prefix=$out/simple-obfs --host=$host --disable-documentation
make -j$(getconf _NPROCESSORS_ONLN) && make install
popd

popd
