LIC_FILES_CHKSUM="\
    file://COPYING;md5=59530bdf33659b29e73d4adb9f9f6552\
    file://COPYING.LIB;md5=9f604d8a4f8e74f4f5140845a21b6674\
    file://COPYING3;md5=d32239bcb673463ab874e80d47fae504\
    file://COPYING3.LIB;md5=6a6a8e020838b23406c81b19c1d46df6\
    file://gas/COPYING;md5=d32239bcb673463ab874e80d47fae504\
    file://include/COPYING;md5=59530bdf33659b29e73d4adb9f9f6552\
    file://include/COPYING3;md5=d32239bcb673463ab874e80d47fae504\
    file://libiberty/COPYING.LIB;md5=a916467b91076e631dd8edb7424769c7\
    file://bfd/COPYING;md5=d32239bcb673463ab874e80d47fae504\
    "

def binutils_branch_version(d):
    pvsplit = d.getVar('PV').split('.')
    return pvsplit[0] + "_" + pvsplit[1]

# When upgrading to 2.37, please make sure there is no trailing .0, so
# that upstream version check can work correctly.
PV = "2.37"
CVE_VERSION = "2.37"

SRC_URI = "file://binutils/${BP}.tar.xz \
	   file://binutils/backport-CVE-2021-45078.patch \
	   file://binutils/binutils-2.20.51.0.2-libtool-lib64.patch \
	   file://binutils/binutils-2.22.52.0.4-no-config-h-check.patch \
	   file://binutils/CVE-2019-1010204.patch \
	   file://binutils/binutils-2.27-aarch64-ifunc.patch \
	   file://binutils/export-demangle.h-in-devel-package.patch \
	   file://binutils/Fix-a-potential-use-of-an-uninitialised-value-in-the.patch \
	   file://0005-Point-scripts-location-to-libdir.patch \
"

S  = "${WORKDIR}/${BP}"
