# main bbfile: yocto-poky/meta/recipes-devtools/squashfs-tools/squashfs-tools_git.bb

# version in openEuler
PV = "4.6.1"

FILESEXTRAPATHS:append := "${THISDIR}/files/:"

LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

S = "${WORKDIR}/${BP}"

# files, patches that come from openeuler
SRC_URI = " \
        file://squashfs${PV}.tar.gz \
        "

SRC_URI[md5sum] = "db23a40fa0dc54b4d6d225fb20ee6555"
SRC_URI[sha256sum] = "94201754b36121a9f022a190c75f718441df15402df32c2b520ca331a107511c"

do_compile() {
        cd ${S}/squashfs-tools
        oe_runmake all
}

do_install() {
       cd ${S}/squashfs-tools
       install -d "${D}${includedir}"
       oe_runmake install INSTALL_PREFIX=${D}${prefix} INSTALL_MANPAGES_DIR=${D}${datadir}/man/man1
       install -m 0644 "${S}"/squashfs-tools/squashfs_fs.h "${D}${includedir}"
}
