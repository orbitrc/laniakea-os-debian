SRC_DIR = $(PWD)/src
ISO_DIR = $(PWD)/iso

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
	iso/install.amd/ \
	iso/install.amd/initrd.gz \
	iso/isolinux/ \
	iso/pics/ \
	iso/pool/ \
	iso/setup.exe \
	iso/tools/ \

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

iso/install.amd/initrd.gz: iso/
	cp -r $(SRC_DIR)/install.amd/initrd $(ISO_DIR)/install.amd/initrd.d
	cp $(SRC_DIR)/initrd/bin/* $(ISO_DIR)/install.amd/initrd.d/bin/
	cp -r $(SRC_DIR)/initrd/lib/* $(ISO_DIR)/install.amd/initrd.d/lib/
	cp -r $(SRC_DIR)/initrd/usr/lib/* $(ISO_DIR)/install.amd/initrd.d/usr/lib/
	sudo tar xvf $(SRC_DIR)/initrd/dev.tar --directory $(ISO_DIR)/install.amd/initrd.d
	cd $(ISO_DIR)/install.amd/initrd.d ; find . -depth -print | sort | sudo cpio -oaV -H newc --owner=root -O $(ISO_DIR)/install.amd/initrd
	# sudo rm -rf $(ISO_DIR)/install.amd/initrd.d
	gzip $(ISO_DIR)/install.amd/initrd


iso/:
	mkdir iso


md5sum: $(FILES)
	cd iso ; find . -type f -exec md5sum {} \; > md5sum.txt

clean:
	# rm -rf iso
	rm -rf iso/README.*
	rm -rf iso/isolinux
	rm -rf iso/boot
	rm -f iso/debian
	rm -f iso/install.amd/initrd.gz
	sudo rm -rf iso/install.amd/initrd.d/dev
	rm -rf $(ISO_DIR)/install.amd/initrd.d
