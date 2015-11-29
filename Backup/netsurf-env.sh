TARGET=framebuffer

HOST=linux
BUILD=linux
toolchain=gcc

CC=pcc
BUILD_CC=pcc
HOST_CC=pcc

PREFIX=/Apps/Netsurf
PKG_CONFIG_PATH=$PREFIX/Libraries/pkgconfig
CPPFLAGS="-I/System/include -I$PREFIX/Headers"
CFLAGS="$CPPFLAGS"

LD_LIBRARY_PATH=/Apps/Netsurf/Libraries

export TARGET HOST BUILD toolchain CC BUILD_CC HOST_CC PREFIX \
	PKG_CONFIG_PATH CFLAGS CPPFLAGS LD_LIBRARY_PATH
