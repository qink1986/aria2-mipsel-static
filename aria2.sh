#!/bin/bash

set -e
set -x

# mkdir ~/aria2 && cd ~/aria2

PREFIX=/opt

BASE=`pwd`
SRC=$BASE/src
WGET="tsocks wget --prefer-family=IPv4"
DEST=$BASE$PREFIX
LDFLAGS="-L$DEST/lib -Wl,--gc-sections"
CPPFLAGS="-I$DEST/include"
CFLAGS="-mtune=mips32 -mips32 -O3 -ffunction-sections -fdata-sections"
SQ_CFLAGS="-mtune=mips32 -mips32 -O3 -ffunction-sections -fdata-sections -lpthread -ldl"
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=$PREFIX --host=mipsel-openwrt-linux"
MAKE="make -j`nproc`"
TOOLCHAINE_DIR="$BASE/OpenWrt-Toolchain-ramips-for-mipsel_24kec+dsp-gcc-4.8-linaro_uClibc-0.9.33.2/toolchain-mipsel_24kec+dsp_gcc-4.8-linaro_uClibc-0.9.33.2"

# mkdir $SRC

# export PATH=$PATH:$TOOLCHAINE_DIR/bin

# ######## ####################################################################
# # ZLIB # ####################################################################
# ######## ####################################################################

# mkdir $SRC/zlib && cd $SRC/zlib
# $WGET http://zlib.net/zlib-1.2.11.tar.gz
# tar zxvf zlib-1.2.11.tar.gz
# cd zlib-1.2.11

# LDFLAGS=$LDFLAGS \
# 	CPPFLAGS=$CPPFLAGS \
# 	CFLAGS=$CFLAGS \
# 	CXXFLAGS=$CXXFLAGS \
# 	CROSS_PREFIX=mipsel-openwrt-linux- \
# 	./configure \
# 	--prefix=$PREFIX

# $MAKE
# make install DESTDIR=$BASE

# ########### #################################################################
# # OPENSSL # #################################################################
# ########### #################################################################

# mkdir -p $SRC/openssl && cd $SRC/openssl
# $WGET https://www.openssl.org/source/openssl-1.0.2g.tar.gz
# tar zxvf openssl-1.0.2g.tar.gz
# cd openssl-1.0.2g

# ./Configure linux-mips32 \
# 	-mtune=mips32 -mips32 \
# 	-ffunction-sections -fdata-sections -Wl,--gc-sections \
# 	--prefix=$PREFIX shared zlib \
# 	--with-zlib-lib=$DEST/lib \
# 	--with-zlib-include=$DEST/include

# make CC=mipsel-openwrt-linux-gcc
# make CC=mipsel-openwrt-linux-gcc install INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl

# ########## ##################################################################
# # SQLITE # # v3.12.1 ########################################################
# ########## ##################################################################

# mkdir $SRC/sqlite && cd $SRC/sqlite
# $WGET https://www.sqlite.org/cgi/src/tarball/e4ab094f/SQLite-e4ab094f.tar.gz --no-check-certificate
# tar zxvf SQLite-e4ab094f.tar.gz
# cd SQLite-e4ab094f

# LDFLAGS=$LDFLAGS \
# 	CPPFLAGS=$CPPFLAGS \
# 	CFLAGS=$SQ_CFLAGS \
# 	CXXFLAGS=$CXXFLAGS \
# 	$CONFIGURE

# $MAKE
# make install DESTDIR=$BASE

# ########### #################################################################
# # LIBXML2 # #################################################################
# ########### #################################################################

# mkdir $SRC/libxml2 && cd $SRC/libxml2
# $WGET ftp://xmlsoft.org/libxml2/libxml2-2.9.3.tar.gz
# tar zxvf libxml2-2.9.3.tar.gz
# cd libxml2-2.9.3

# LDFLAGS=$LDFLAGS \
# 	CPPFLAGS=$CPPFLAGS \
# 	CFLAGS=$CFLAGS \
# 	CXXFLAGS=$CXXFLAGS \
# 	$CONFIGURE \
# 	--with-zlib=$DEST \
# 	--without-python

# $MAKE LIBS="-lz"
# make install DESTDIR=$BASE

# ########## ##################################################################
# # C-ARES # ##################################################################
# ########## ##################################################################

# mkdir $SRC/c-ares && cd $SRC/c-ares
# $WGET http://c-ares.haxx.se/download/c-ares-1.11.0.tar.gz
# tar zxvf c-ares-1.11.0.tar.gz
# cd c-ares-1.11.0

# LDFLAGS=$LDFLAGS \
# 	CPPFLAGS=$CPPFLAGS \
# 	CFLAGS=$CFLAGS \
# 	CXXFLAGS=$CXXFLAGS \
# 	$CONFIGURE

# $MAKE
# make install DESTDIR=$BASE

########### #################################################################
# LIBSSH2 # #################################################################
########### #################################################################

rm -rf $SRC/libssh2  #REMOVE WHEN FINISH ##################################################################
mkdir $SRC/libssh2 && cd $SRC/libssh2
$WGET http://www.libssh2.org/download/libssh2-1.7.0.tar.gz
tar zxvf libssh2-1.7.0.tar.gz
cd libssh2-1.7.0

LDFLAGS=$LDFLAGS \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	./configure --prefix=$PREFIX --host=mipsel-openwrt-linux --with-libssl-prefix=$DEST

$MAKE LIBS="-lz -lssl -lcrypto"
make install DESTDIR=$BASE

######### ###################################################################
# ARIA2 # ###################################################################
######### ###################################################################

mkdir $SRC/aria2 && cd $SRC/aria2
$WGET https://github.com/aria2/aria2/releases/download/release-1.34.0/aria2-1.34.0.tar.gz
tar zxvf aria2-1.34.0.tar.gz
cd aria2-1.34.0

LDFLAGS="-zmuldefs $LDFLAGS" \
	CPPFLAGS=$CPPFLAGS \
	CFLAGS=$CFLAGS \
	CXXFLAGS=$CXXFLAGS \
	$CONFIGURE \
	--enable-libaria2 \
	--enable-static \
	--disable-shared \
	--without-libuv \
	--without-appletls \
	--without-gnutls \
	--without-libnettle \
	--without-libgmp \
	--without-libgcrypt \
	--without-libexpat \
	--with-xml-prefix=$DEST \
	ZLIB_CFLAGS="-I$DEST/include" \
	ZLIB_LIBS="-L$DEST/lib" \
	OPENSSL_CFLAGS="-I$DEST/include" \
	OPENSSL_LIBS="-L$DEST/lib" \
	SQLITE3_CFLAGS="-I$DEST/include" \
	SQLITE3_LIBS="-L$DEST/lib" \
	LIBCARES_CFLAGS="-I$DEST/include" \
	LIBCARES_LIBS="-L$DEST/lib" \
	LIBSSH2_CFLAGS="-I$DEST/include" \
	LIBSSH2_LIBS="-L$DEST/lib" \
	ARIA2_STATIC=yes

$MAKE LIBS="-lz -lssl -lcrypto -lsqlite3 -lcares -lxml2 -lssh2"
make install DESTDIR=$BASE/aria2

