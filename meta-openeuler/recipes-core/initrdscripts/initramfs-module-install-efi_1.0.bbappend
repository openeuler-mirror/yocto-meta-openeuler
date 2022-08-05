# main bbfile: yocto-poky/meta/recipes-core/initrdscripts/initramfs-module-install-efi_1.0.bb

FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

SRC_URI += "file://init-install-efi-openeuler.sh"

RDEPENDS_${PN}_remove = "initramfs-framework-base"

do_install_append() {
    install -m 0755 ${WORKDIR}/init-install-efi-openeuler.sh ${D}/init.d/install-efi.sh
}

