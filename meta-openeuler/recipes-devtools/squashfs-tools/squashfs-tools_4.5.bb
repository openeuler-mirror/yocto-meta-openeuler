# Note, we can probably remove the lzma option as it has be replaced with xz,
# and I don't think the kernel supports it any more.
SUMMARY = "Tools for manipulating SquashFS filesystems"
HOMEPAGE = "https://github.com/plougher/squashfs-tools"
DESCRIPTION = "Tools to create and extract Squashfs filesystems."
SECTION = "base"
LICENSE = "GPL-2"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SRC_URI = "file://squashfs-tools/squashfs4.5.tar.gz \
	   file://squashfs-tools/0001-CVE-2021-41072.patch \
           file://squashfs-tools/0002-CVE-2021-41072.patch \
           file://squashfs-tools/0003-CVE-2021-41072.patch \
           file://squashfs-tools/0004-CVE-2021-41072.patch \
           file://squashfs-tools/0005-CVE-2021-41072.patch \
"

S = "${WORKDIR}/${BP}"
B = "${S}/${PN}"

EXTRA_OEMAKE = "${PACKAGECONFIG_CONFARGS}"

PACKAGECONFIG ??= "gzip xz xattr"
PACKAGECONFIG[gzip] = "GZIP_SUPPORT=1,GZIP_SUPPORT=0,zlib"
PACKAGECONFIG[xz] = "XZ_SUPPORT=1,XZ_SUPPORT=0,xz"
PACKAGECONFIG[xattr] = "XATTR_SUPPORT=1,XATTR_SUPPORT=0,attr"

do_compile() {
	oe_runmake all
}

do_install() {
	oe_runmake install INSTALL_DIR=${D}${sbindir}
}

ARM_INSTRUCTION_SET_armv4 = "arm"
ARM_INSTRUCTION_SET_armv5 = "arm"
ARM_INSTRUCTION_SET_armv6 = "arm"

BBCLASSEXTEND = "native nativesdk"

CVE_PRODUCT = "squashfs"
