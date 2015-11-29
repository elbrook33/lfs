## Perl ##
./build-single-app-gcc Perl ../Sources/Extras/perl-*

## Netsurf ##
openssl (a patch, edit Makefile to add -fPIC)
curl (a patch)
yasm
libjpeg-turbo (without simd, CXXCPP="pcc -E")
zlib
libpng
giflib (probably unnecessary - libnsgif)
bison/flex
netsurf
	disable svgtiny, which needs gperf, which is C++ so can't run without GCC and stdlibc++
	edit utils/split_messages.pl (need cpan HTML::Entities - it's just subbing &, < and > anyway)
	set LD_LIBRARY_PATH
	set PKG_CONFIG_PATH in top-level Makefile
	add `pkg-config --cflags libpng` and `pkg-config --libs libpng` to Makefile.target for convert_image
	sed -i.old 's/enum browser_mouse_state;/#include "desktop\/mouse.h"/g' netsurf/desktop/*
	sed -i 's/enum content_debug;/#include "content\/content.h"/g' netsurf/desktop/browser.h
	netsurf -f linux