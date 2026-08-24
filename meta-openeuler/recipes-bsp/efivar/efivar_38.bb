SUMMARY = "Tools to manipulate UEFI variables"
DESCRIPTION = "efivar provides a simple command line interface to the UEFI variable facility"
HOMEPAGE = "https://github.com/rhboot/efivar"

LICENSE = "LGPL-2.1-or-later"
LIC_FILES_CHKSUM = "file://COPYING;md5=6626bb1e20189cfa95f2c508ba286393"

COMPATIBLE_HOST = "(i.86|x86_64|arm|aarch64).*-linux"

SRC_URI = "git://github.com/rhinstaller/efivar.git;branch=main;protocol=https \
           file://0001-docs-do-not-build-efisecdb-manpage.patch \
           "
SRCREV = "c47820c37ac26286559ec004de07d48d05f3308c"

S = "${WORKDIR}/git"

inherit pkgconfig

export CCLD_FOR_BUILD = "${BUILD_CCLD}"

do_compile() {
    oe_runmake ERRORS= HOST_CFLAGS="${BUILD_CFLAGS}" HOST_LDFLAGS="${BUILD_LDFLAGS}"
}

do_install() {
    oe_runmake install DESTDIR=${D}
}

BBCLASSEXTEND = "native"

RRECOMMENDS:${PN}:class-target = "kernel-module-efivarfs"

CLEANBROKEN = "1"

# With the clang toolchain + ld-is-lld, libefisec.so fails to link because:
#   ld.lld: error: unknown argument '--add-needed'
# efivar's defaults.mk hardcodes -Wl,--add-needed (a legacy GNU ld no-op flag)
# in its "override LDFLAGS = ..." (the override keyword blocks Yocto's
# LDFLAGS from removing it). lld rejects this flag, so strip the line from
# defaults.mk before compiling when lld is the linker.
do_compile:prepend() {
    if echo "${LDFLAGS}" | grep -q "fuse-ld=lld"; then
        # efivar's defaults.mk hardcodes -Wl,--add-needed (a legacy GNU ld
        # no-op) in its "override LDFLAGS = ..."; lld rejects it with
        # "unknown argument '--add-needed'". Strip the line.
        sed -i '/--add-needed/d' "${S}/src/include/defaults.mk"
    fi
}
