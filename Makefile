SRC_DIR = $(PWD)/src
ISO_DIR = $(PWD)/iso

VERSION = 0.1.0-alpha1
CODENAME = os0

LIBC_VERSION = $(shell cat versions | grep LIBC_ | cut -d '=' -f 2)
UTIL_LINUX_VERSION = $(shell cat versions | grep UTIL_LINUX_ | cut -d '=' -f 2)
include versions

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
	iso/packages/ \
	iso/system/ \
	iso/install/ \
	iso/install/initrd.gz \
	iso/isolinux/ \
	iso/pics/ \
	iso/pool/ \
	iso/setup.exe \
	iso/tools/ \
	iso/.disk/ \
	iso/.disk/info

EMPTY_DIRS = src/install/initrd/var/cache/anna \
	src/install/initrd/var/lib/apt-install \
	src/install/initrd/var/lib/cdebconf \
	src/install/initrd/var/lib/localechooser \
	src/install/initrd/var/lib/preseed \
	src/install/initrd/var/log \
	src/install/initrd/var/run/brltty

PACKAGES = packages/libc6_$(LIBC_VERSION)_amd64.tar.xz \
	packages/util-linux_$(UTIL_LINUX_VERSION)_amd64.tar.xz

default: md5sum
	./isochmod.sh

iso/md5sum.txt:
	cd src ; find . -type f -exec md5sum {} \; > ../iso/md5sum.txt

iso/README.%: src/README.% iso/
	cp $< $@

iso/g2ldr iso/g2ldr.mbr: src/g2ldr src/g2ldr.mbr iso/
	cp $< $@

iso/debian: iso/
	ln -s . iso/debian

iso/css/: iso/
	cp -r src/css iso/css

iso/doc: iso/
	cp -r src/doc iso/doc

iso/efi: iso/
	cp -r src/efi iso/efi

iso/boot/: iso/
	cp -r src/boot iso/boot

iso/isolinux/: iso/
	cp -r src/isolinux iso/isolinux

iso/.disk/: iso/
	cp -r src/.disk iso/.disk

iso/.disk/info: iso/.disk/
	sed 's/$$(VERSION)/$(VERSION)/' src/.disk/info.src | sed 's/$$(CODENAME)/$(CODENAME)/' > iso/.disk/info
	rm -f iso/.disk/info.src

iso/system/: iso/
	cp -r src/system iso/system
	sed 's/$$(VERSION)/$(VERSION)/' src/system/usr/lib/os-release.src | sed 's/$$(CODENAME)/$(CODENAME)/' > iso/system/usr/lib/os-release
	rm -f iso/system/usr/lib/os-release.src

iso/packages/: iso/
	cp -r packages $(ISO_DIR)/

iso/install/initrd.gz: iso/ $(PACKAGES) $(EMPTY_DIRS)
	@#=======================
	@# Copy common files.
	@#=======================
	cp $(SRC_DIR)/install/vmlinuz $(ISO_DIR)/install/vmlinuz
	cp -r $(SRC_DIR)/install/initrd $(ISO_DIR)/install/initrd.d
	cp $(SRC_DIR)/initrd/bin/* $(ISO_DIR)/install/initrd.d/bin/
	cp -r $(SRC_DIR)/initrd/lib/* $(ISO_DIR)/install/initrd.d/lib/
	cp -r $(SRC_DIR)/initrd/usr/lib/* $(ISO_DIR)/install/initrd.d/usr/lib/
	sudo tar xvf $(SRC_DIR)/initrd/dev.tar --directory $(ISO_DIR)/install/initrd.d
	@#=======================
	@# Make initrd
	@#=======================
	cd $(ISO_DIR)/install/initrd.d ; find . -depth -print | sort | sudo cpio -oaV -H newc --owner=root -O $(ISO_DIR)/install/initrd
	sudo rm -rf $(ISO_DIR)/install/initrd.d
	gzip $(ISO_DIR)/install/initrd

iso/:
	mkdir iso

$(EMPTY_DIRS):
	mkdir -p $@

packages/libc6_$(LIBC_VERSION)_amd64.tar.xz:
	./download.sh

md5sum: $(FILES)
	cd iso ; find . -type f -exec md5sum {} \; > md5sum.txt

clean:
	# rm -rf iso
	rm -rf iso/README.*
	rm -f iso/g2ldr*
	rm -rf iso/css iso/doc iso/efi
	rm -rf iso/isolinux
	rm -rf iso/boot
	rm -f iso/debian
	rm -rf iso/.disk
	rm -rf iso/system
	rm -rf iso/packages
	rm -f iso/install/initrd.gz
	sudo rm -rf iso/install/initrd.d/dev
	rm -rf $(ISO_DIR)/install/initrd.d
	rm -rf $(ISO_DIR)/install/vmlinuz
	rmdir $(EMPTY_DIRS)

purge: clean
	rm -rf packages/*.tar.xz

