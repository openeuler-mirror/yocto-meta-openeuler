# main bb file: yocto-poky/meta/recipes-devtools/syslinux/syslinux_6.04-pre2.bb
# isolinux.bin is used to support PCBIOS startup ISO, which is also the bootloader like grub

# version in openEuler
PV = "6.04-pre1"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
        https://www.zytor.com/pub/syslinux/Testing/6.04/syslinux-${PV}.tar.xz \
	file://determinism.patch \
"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://${BP}.tar.xz;name=tarball \
    file://0001-Add-install-all-target-to-top-side-of-HAVE_FIRMWARE.patch \
    file://0002-ext4-64bit-feature.patch \
    file://0003-include-sysmacros-h.patch \
    file://backport-replace-builtin-strlen-that-appears-to-get-optimized.patch \
    file://backport-add-RPMOPTFLAGS-to-CFLAGS-for-some-stuff.patch \
    file://backport-tweak-for-gcc-10.patch \
    file://backport-zlib-update.patch \
"

SRC_URI[tarball.md5sum] = "f9c956fde0de29be297402ecbc8ff4d0"
SRC_URI[tarball.sha256sum] = "3f6d50a57f3ed47d8234fd0ab4492634eb7c9aaf7dd902f33d3ac33564fd631d"

do_install:append() {
	install -d ${D}${datadir}/syslinux/
	install -m 644 ${S}/bios/core/isolinux.bin ${D}${datadir}/syslinux/
	install -m 644 ${S}/bios/com32/elflink/ldlinux/ldlinux.c32 ${D}${datadir}/syslinux/
}
