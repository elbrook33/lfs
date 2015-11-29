#!/bin/sh

install_path=/root/Documents/Crap/LFS/mnt

#
# Steps:
# 1) Create partition (parted or dd). Format (mkfs.ext4). Mount.
# 2) Copy kernel files into a "System" folder. (image, Startup and Shutdown plus headers - make INSTALL_HDR_PATH=$install_path/System headers_install; and modules - make INSTALL_MOD_PATH=$install_path/System modules_install)
# 3) Run this build script.
# 4) Make folders on partition: /bin /dev /etc /proc /sys /tmp
# 5) Copy fstab into /etc. (Change partition number if necessary.)
#

## Setup ##
setPaths() {
pathopts="\
	--prefix=/Software/$1
	--bindir=/Software/$1
	--sbindir=/Software/$1
	--libexecdir=/Software/$1/Internal
	--sysconfdir=/Software/$1/Settings
	--localstatedir=/Software/$1/Workspace
	--libdir=/Software/$1/Libraries
	--includedir=/Software/$1/Headers
	--datarootdir=/Software/$1/Resources"
}

buildPkg() {
	pkg=`tar -tf $1 | head -n 1 | cut -d "/" -f 1`
	name=${pkg%-*}
	tar -xf $1
	pushd $pkg
		./configure $pathopts $2
		if [ -f ../$name.patch ] ; then patch -p2 <../$name.patch ; fi
		make
		#make check
		make install DESTDIR=$install_path # Extra arg (exception for bzip2)
	popd
	rm -R $pkg
}


# Compilers

## Build musl (C library) ##
export CC=gcc
export CFLAGS="-fPIC"
setPaths "Compilers"
buildPkg "../Sources/Core/musl-1.1.12.tar.gz" "--syslibdir=/Software/Compilers/Libraries"

## Setup to build compilers using musl ##
gcc_cc="$install_path/Software/Compilers/musl-gcc"
pcc_cc="$install_path/Software/Compilers/pcc"
base_cflags="-fPIC -I$install_path/System/include"
ln -s $install_path/Software /
export CC=$gcc_cc
export CFLAGS="$base_cflags"

## Binutils and Portable C Compiler (patched to link with musl) ##
setPaths "Compilers"
buildPkg "../Sources/Core/binutils-2.25.1.tar.bz2" "--with-lib-path=/Software/Compilers/Libraries"
buildPkg "../Sources/Core/pcc-1.1.0.tgz" "--with-incdir=/Software/Compilers/Headers --with-libdir=/Software/Compilers/Libraries"
buildPkg "../Sources/Core/pcc-libs-1.1.0.tgz"

## Build the rest using pcc (instead of gcc) ##
export CC=$pcc_cc


# Archivers
setPaths "Archivers"
buildPkg "../Sources/Core/tar-1.28.tar.xz" "FORCE_UNSAFE_CONFIGURE=1"
buildPkg "../Sources/Core/gzip-1.6.tar.xz"
buildPkg "../Sources/Core/xz-5.2.1.tar.xz"

# _nix-shell
setPaths "_nix-shell"
buildPkg "../Sources/Core/coreutils-8.24.tar.xz" "FORCE_UNSAFE_CONFIGURE=1"
buildPkg "../Sources/Core/findutils-4.4.2.tar.gz"
buildPkg "../Sources/Core/gawk-4.1.3.tar.xz"
buildPkg "../Sources/Core/grep-2.21.tar.xz"
buildPkg "../Sources/Core/sed-4.2.2.tar.bz2"
export CC=$gcc_cc
buildPkg "../Sources/Core/bash-4.3.30.tar.gz" "--without-bash-malloc --enable-static-link"
ln -s /Software/_nix-shell/bash $install_path/bin/sh
export CC=$pcc_cc

# Build-tools
setPaths "Build-tools"
buildPkg "../Sources/Core/diffutils-3.3.tar.xz"
buildPkg "../Sources/Core/m4-1.4.17.tar.xz"
buildPkg "../Sources/Core/make-4.1.tar.bz2" "--without-guile"
buildPkg "../Sources/Core/patch-2.7.5.tar.xz"
export CC=$gcc_cc
buildPkg "../Sources/Core/pkg-config-0.29.tar.gz" "--with-internal-glib" # Error about #pragmas with pcc
export CC=$pcc_cc

# Hardware (tools)
setPaths "Hardware"
export CC=$gcc_cc
buildPkg "../Sources/Core/e2fsprogs-1.42.13.tar.gz"
buildPkg "../Sources/Core/kmod-21.tar.xz"
ln -s kmod /Software/Hardware/depmod
ln -s kmod /Software/Hardware/insmod
ln -s kmod /Software/Hardware/lsmod
ln -s kmod /Software/Hardware/modinfo
ln -s kmod /Software/Hardware/modprobe
ln -s kmod /Software/Hardware/rmmod
buildPkg "../Sources/Core/util-linux-2.27.tar.xz" "--without-python --without-ncurses"
export CC=$pcc_cc


# Cleanup
rm /Software
