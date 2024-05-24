FILESEXTRAPATHS:append := "${THISDIR}/files/:"

PV = "6.1.46"

OPENEULER_REPO_NAME = "myir-ti-linux"

# ti-layer have overwrite do_configure to deal with defconfig in meta-ti-bsp/recipes-kernel/linux/setup-defconfig.inc

SRC_URI = " \
    file://myir-ti-linux \
    file://defconfig \
"

S = "${WORKDIR}/myir-ti-linux"

KERNEL_LOCALVERSION = ""

RDEPENDS:${KERNEL_PACKAGE_NAME}-image = ""

CREATE_SRCIPK:k3 = "0"

FILES:kernel-custom-dtb = "/boot/dtb/myir/*"
PACKAGES += "kernel-custom-dtb"

do_install:append (){
    # move all dtb files to /boot/dtb/myir because of uboot variable
    install -d ${D}/boot/dtb/myir
    cp ${D}/boot/*.dtb ${D}/boot/*.dtbo ${D}/boot/dtb/myir
}
