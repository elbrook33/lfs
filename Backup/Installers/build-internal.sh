install_path=$3
type=$4

## Setup ##
setPaths() {
pathopts="\
	--prefix=/$type/$1
	--bindir=/$type/$1
	--sbindir=/$type/$1
	--libexecdir=/$type/$1/Internal
	--sysconfdir=/$type/$1/Settings
	--localstatedir=/$type/$1/Workspace
	--libdir=/$type/$1/Libraries
	--includedir=/$type/$1/Headers
	--datadir=/$type/$1/Resources"
#	--datarootdir=/$type/$1/Resources
}

buildPkg() {
	pkg=`tar -tf $1 | head -n 1 | cut -d "/" -f 1` # Package name with version (e.g. app-2.1.4)
	name=${pkg%%-*} # Package name without version (e.g. app)
	tar -xf $1
	pushd $pkg
		./configure $pathopts $2
		if [ -f ../$name.patch ] ; then patch -p1 < ../$name.patch ; fi
		make
		make install DESTDIR=$install_path
	popd
}

export CC=pcc
export CPP="pcc -E"
export CPPFLAGS="-I/System/include -I/Software/Hardware/Headers -I/$type/$1/Headers"
export CFLAGS="$CFLAGS -fPIC"
export LDFLAGS="-L/Software/Hardware/Libraries -L/$type/$1/Libraries"
export PKG_CONFIG_PATH="/$type/$1/Libraries/pkgconfig"

setPaths $1
buildPkg $2 "$5"

. refresh-paths
