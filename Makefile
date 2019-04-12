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
	iso/install/initrd.gz \
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

iso/install/initrd.gz: iso/
	#=======================
	# Copy common files.
	#=======================
	cp $(SRC_DIR)/install/vmlinuz $(ISO_DIR)/install/vmlinuz
	cp -r $(SRC_DIR)/install/initrd $(ISO_DIR)/install/initrd.d
	cp $(SRC_DIR)/initrd/bin/* $(ISO_DIR)/install/initrd.d/bin/
	cp -r $(SRC_DIR)/initrd/lib/* $(ISO_DIR)/install/initrd.d/lib/
	cp -r $(SRC_DIR)/initrd/usr/lib/* $(ISO_DIR)/install/initrd.d/usr/lib/
	sudo tar xvf $(SRC_DIR)/initrd/dev.tar --directory $(ISO_DIR)/install/initrd.d
	#=======================
	# Make initrd
	#=======================
	cd $(ISO_DIR)/install/initrd.d ; find . -depth -print | sort | sudo cpio -oaV -H newc --owner=root -O $(ISO_DIR)/install/initrd
	sudo rm -rf $(ISO_DIR)/install/initrd.d
	gzip $(ISO_DIR)/install/initrd


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
	rm -f iso/install/initrd.gz
	sudo rm -rf iso/install/initrd.d/dev
	rm -rf $(ISO_DIR)/install/initrd.d
	rm -rf $(ISO_DIR)/install/vmlinuz
