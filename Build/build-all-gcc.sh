#!/bin/sh

install_path=/root/Documents/Crap/LFS/mnt

#
# Steps:
# 1) Create partition (parted or dd). Format (mkfs.ext4). Mount.
# 2) Create "System" folder on partition. Copy kernel headers (make INSTALL_HDR_PATH=$install_path/System headers_install) into folder. Copy kernel image and startup script into System folder. (Usually as "Kernel" and "Startup".) Copy kernel modules (make INSTALL_MOD_PATH=$install_path/System modules_install).
# 3) Make folders on partition: /bin /dev /etc /proc /sys /tmp
# 4) Set install_path (above) to mountpoint. Run this build script.
# 5) Copy fstab into /etc. (Change partition number if necessary.)
#

## Setup ##
setPaths() {
pathopts="\
	--prefix=/Core/$1
	--bindir=/Core/$1
	--sbindir=/Core/$1
	--libexecdir=/Core/$1/Internal
	--sysconfdir=/Core/$1/Settings
	--localstatedir=/Core/$1/Workspace
	--libdir=/Core/$1/Libraries
	--includedir=/Core/$1/Headers
	--datarootdir=/Core/$1/Resources"
}

buildPkg() {
	pkg=`tar -tf $1 | head -n 1 | cut -d "/" -f 1`
	name=${pkg%-*}
	tar -xf $1
	if [ $3 == "in-tree" ] ; then pushd $pkg
	else mkdir build-$pkg && pushd build-$pkg
	fi
		if [ $2 != "config-sh" ] ; then ./configure $pathopts $2 ; fi
		if [ -f ../$name.patch ] ; then patch -p2 <../$name.patch ; fi
		if [ $2 == "config-sh" ] ; then ./config.sh ; fi
		make
		#make check
		make install DESTDIR=$install_path
	popd
	if [ $3 != "in-tree" ] ; then rm -R build-$pkg ; fi
	rm -R $pkg
}


# 1. Compilers

## Musl (C library) ##
export CFLAGS="-fPIC"
setPaths "Compilers"
buildPkg ../Sources/Core/musl-* "--syslibdir=/Software/Core/Libraries" "in-tree"

## Setup to build compilers using musl ##
ln -s $install_path/Core /
export CC="/Software/Core/musl-gcc"
export CFLAGS="-I$install_path/System/include"

## Binutils and GCC ##
setPaths "Compilers"
buildPkg ../Sources/Core/binutils-* "--with-lib-path=/Software/Core/Libraries"
buildPkg ../Sources/Unused/gmp-*
mv /Software/Core/include/* /Software/Compilers/Headers/
rmdir /Software/Core/include
buildPkg ../Sources/Core/mpfr-*
buildPkg ../Sources/Core/mpc-*
buildPkg ../Sources/Core/gcc-* "--with-native-system-header-dir=/Core/Compilers/Headers --with-local-prefix=/Core/Compilers --with-newlib \
	--disable-multilib --disable-bootstrap --disable-shared --disable-nls \
	--disable-decimal-float, --disable-threads, --disable-libatomic, --disable-libgomp, --disable-libquadmath, --disable-libssp, --disable-libvtv, --disable-libstdcxx"


# 2. Archivers
setPaths "Archivers"
buildPkg ../Sources/Core/tar-* "FORCE_UNSAFE_CONFIGURE=1"
buildPkg ../Sources/Core/gzip-*
buildPkg ../Sources/Core/xz-*


# 3. _nix-shell
setPaths "_nix-shell"
buildPkg ../Sources/Core/bash-* "--without-bash-malloc --enable-static-link"
ln -sf /Software/_nix-shell/bash $install_path/bin/sh
buildPkg ../Sources/Core/coreutils-* "FORCE_UNSAFE_CONFIGURE=1"
buildPkg ../Sources/Core/findutils-*
buildPkg ../Sources/Core/gawk-*
buildPkg ../Sources/Core/grep-*
buildPkg ../Sources/Core/less-*
buildPkg ../Sources/Core/nano-*
buildPkg ../Sources/Core/ncurses-*
buildPkg ../Sources/Core/psmisc-*
buildPkg ../Sources/Core/sed-*


# 4. Build-tools
setPaths "Build-tools"
buildPkg ../Sources/Core/diffutils-*
buildPkg ../Sources/Core/m4-*
buildPkg ../Sources/Core/make-* "--without-guile"
buildPkg ../Sources/Core/patch-*
buildPkg ../Sources/Core/pkg-config-* "--with-internal-glib" # Error about #pragmas with pcc


# 5. Hardware-tools
setPaths "Hardware-tools"
buildPkg ../Sources/Core/e2fsprogs-*
buildPkg ../Sources/Core/kmod-*
ln -s kmod /Core/Hardware-tools/depmod
ln -s kmod /Core/Hardware-tools/insmod
ln -s kmod /Core/Hardware-tools/lsmod
ln -s kmod /Core/Hardware-tools/modinfo
ln -s kmod /Core/Hardware-tools/modprobe
ln -s kmod /Core/Hardware-tools/rmmod
buildPkg ../Sources/Core/util-linux-* "--without-python --without-ncurses"


# 6. Networking
setPaths "Networking"
buildPkg ../Sources/Core/inetutils-*
buildPkg ../Sources/Core/dhcphd-*


# 7. Perl
buildPkg ../Sources/Core/perl-* "config-sh"


## Cleanup ##
rm /Software
