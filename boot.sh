#!/bin/sh

qemu-system-x86_64 \
	-m 768M \
	-netdev user,id=qemu_net0 \
	-device pcnet,netdev=qemu_net0 \
	-kernel Linux-kernel \
	-append "root=/dev/sda rootfstype=ext4 init=/System/Startup quiet video=vesa vga=0x303" \
	-drive file=/dev/sda9,format=raw \
	-enable-kvm
