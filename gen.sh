#!/bin/sh

BUILD_VERSION="false"
VERSION="0.1.0-alpha1"
if [ "$BUILD_VERSION" = "true" ]; then
	VERSION="$VERSION.`date -u +%Y%m%d%H%M`"
fi

# genisoimage -o your-new.iso -b iso/isolinux/isolinux.bin -c iso/isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V "Your Disk Name Here" .
genisoimage -o laniakea_$VERSION\_amd64.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V "Your Disk Name Here" iso/

if [ $? = 0 ]; then
	echo "====================================="
	echo "laniakea_${VERSION}_amd64.iso"
else
	echo "Failed to generate ISO image."
	exit 1
fi
