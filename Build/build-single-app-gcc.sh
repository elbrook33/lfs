#!/bin/sh

install_path=/root/Documents/Crap/LFS/mnt

setPaths() {
pathopts="\
	--prefix=/Apps/$1
	--bindir=/Apps/$1
	--sbindir=/Apps/$1
	--libexecdir=/Apps/$1/Internal
	--sysconfdir=/Apps/$1/Settings
	--localstatedir=/Apps/$1/Workspace
	--libdir=/Apps/$1/Libraries
	--includedir=/Apps/$1/Headers
	--datarootdir=/Apps/$1/Resources"
}

buildPkg() {
	pkg=`tar -tf $1 | head -n 1 | cut -d "/" -f 1`
	name=${pkg%-*}
	tar -xf $1
	pushd $pkg
		./configure $pathopts $2
	#	./Configure # For Perl
	#mkdir build-$pkg
	#pushd build-$pkg
	#	../$pkg/configure $pathopts $2
		if [ -f ../$name.patch ] ; then patch -p1 <../$name.patch ; fi
		make
		#make check
		make install DESTDIR=$install_path # Extra arg (exception for bzip2)
	popd
	#rm -R build-$pkg
	rm -R $pkg
}

## Setup to build compilers using musl ##
gcc_cc="$install_path/Software/Compilers/musl-gcc"
pcc_cc="$install_path/Software/Compilers/pcc"
base_cflags="-I$install_path/System/include -I/Software/Hardware-tools/Headers -I/Apps/$1/Headers"
base_ldflags="-L/Software/Hardware-tools/Libraries -L/Apps/$1/Libraries"
ln -s $install_path/Apps /
ln -s $install_path/Software /
export CC=$gcc_cc
export CFLAGS="$base_cflags -w"
export LDFLAGS="$base_ldflags"

setPaths $1
buildPkg $2 "$3"

## Cleanup ##
rm /Apps
rm /Software
