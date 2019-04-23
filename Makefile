SRC_DIR = $(PWD)/src
ISO_DIR = $(PWD)/iso

VERSION = 0.1.0-alpha
CODENAME = os0

LIBC_VERSION = $(shell cat versions | grep LIBC_ | cut -d '=' -f 2)
UTIL_LINUX_VERSION = $(shell cat versions | grep UTIL_LINUX_ | cut -d '=' -f 2)

FILES = iso/README.txt \
	iso/README.source \
	iso/autorun.inf \
	iso/boot/ \
	iso/css/ \
	iso/debian \
	iso/dists \
	iso/doc \
	iso/efi \
	iso/firmware/ \
	iso/g2ldr \
	iso/g2ldr.mbr \
	iso/install/ \
	iso/install/initrd.gz \
	iso/isolinux/ \
	iso/pics/ \
	iso/pool/ \
	iso/setup.exe \
	iso/tools/ \
	iso/.disk/ \
	iso/.disk/info

PACKAGES = packages/libc6_$(LIBC_VERSION)_amd64.tar.xz \
	packages/util-linux_$(UTIL_LINUX_VERSION)_amd64.tar.xz

default: md5sum
	./isochmod.sh

iso/md5sum.txt:
	cd src ; find . -type f -exec md5sum {} \; > ../iso/md5sum.txt

iso/README.%: src/README.% iso/
	cp $< $@

iso/debian: iso/
	ln -s . iso/debian

iso/boot/: iso/
	cp -r src/boot iso/boot

iso/isolinux/: iso/
	cp -r src/isolinux iso/isolinux

iso/.disk/: iso/
	cp -r src/.disk iso/.disk

iso/.disk/info: iso/.disk/
	sed 's/$$(VERSION)/$(VERSION)/' src/.disk/info.src | sed 's/$$(CODENAME)/$(CODENAME)/' > iso/.disk/info
	rm -f iso/.disk/info.src

iso/install/initrd.gz: iso/ $(PACKAGES)
	@#=======================
	@# Copy common files.
	@#=======================
	cp $(SRC_DIR)/install/vmlinuz $(ISO_DIR)/install/vmlinuz
	cp -r $(SRC_DIR)/install/initrd $(ISO_DIR)/install/initrd.d
	cp $(SRC_DIR)/initrd/bin/* $(ISO_DIR)/install/initrd.d/bin/
	cp -r $(SRC_DIR)/initrd/lib/* $(ISO_DIR)/install/initrd.d/lib/
	cp -r $(SRC_DIR)/initrd/usr/lib/* $(ISO_DIR)/install/initrd.d/usr/lib/
	cp -r packages $(ISO_DIR)/install/initrd.d/usr/share/laniakea-installer/
	sudo tar xvf $(SRC_DIR)/initrd/dev.tar --directory $(ISO_DIR)/install/initrd.d
	@#=======================
	@# Make initrd
	@#=======================
	cd $(ISO_DIR)/install/initrd.d ; find . -depth -print | sort | sudo cpio -oaV -H newc --owner=root -O $(ISO_DIR)/install/initrd
	sudo rm -rf $(ISO_DIR)/install/initrd.d
	gzip $(ISO_DIR)/install/initrd

iso/:
	mkdir iso

packages/libc6_$(LIBC_VERSION)_amd64.tar.xz:
	./download.sh

md5sum: $(FILES)
	cd iso ; find . -type f -exec md5sum {} \; > md5sum.txt

clean:
	# rm -rf iso
	rm -rf iso/README.*
	rm -rf iso/isolinux
	rm -rf iso/boot
	rm -f iso/debian
	rm -rf iso/.disk
	rm -f iso/install/initrd.gz
	sudo rm -rf iso/install/initrd.d/dev
	rm -rf $(ISO_DIR)/install/initrd.d
	rm -rf $(ISO_DIR)/install/vmlinuz

purge: clean
	rm -rf packages/*.tar.xz

