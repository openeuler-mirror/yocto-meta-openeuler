# main bbfile: yocto-poky/meta/recipes-devtools/squashfs-tools/squashfs-tools_git.bb

# version in openEuler
PV = "4.5.1"

FILESEXTRAPATHS:append := "${THISDIR}/files/:"

LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

S = "${WORKDIR}/${BP}"

# files, patches that come from openeuler
SRC_URI = " \
        file://${BP}.tar.gz \
        file://0001-install-manpages.sh-do-not-write-original-timestamps.patch \
        "

SRC_URI[md5sum] = "edc3e14508f2716315787b9c88d163a1"
SRC_URI[sha256sum] = "277b6e7f75a4a57f72191295ae62766a10d627a4f5e5f19eadfbc861378deea7"

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
