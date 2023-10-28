OPENEULER_SRC_URI_REMOVE = "git http"

PV = "2.40"
S = "${WORKDIR}/${BPN}-${PV}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:remove:class-nativesdk =  " file://0003-binutils-nativesdk-Search-for-alternative-ld.so.conf.patch "

# apply package source and patches from openeuler
SRC_URI = " \
    file://${BPN}-${PV}.tar.xz \
    file://binutils-libtool-lib64.patch \
    file://binutils-export-demangle.h.patch \
    file://binutils-no-config-h-check.patch \
    file://binutils-2.27-aarch64-ifunc.patch \
    file://binutils-special-sections-in-groups.patch \
    file://binutils-gold-mismatched-section-flags.patch \
    file://binutils-update-linker-manual.patch \
    file://binutils-objcopy-note-merge-speedup.patch \
    file://binutils-reloc-symtab.patch \
    file://binutils-CVE-2023-1972.patch \
    file://binutils-gold-empty-dwp.patch \
    file://0001-X86-Change-fpic-to-fPIC-in-PICFLAG.patch \
"

# apply used patches from poky
SRC_URI += " \
    file://0005-Point-scripts-location-to-libdir.patch \
"

SRC_URI[sha256sum] = "820d9724f020a3e69cb337893a0b63c2db161dadcb0e06fc11dc29eb1e84a32c"

# openeuler configuration

# We do not need gprofng
EXTRA_OECONF:append = " \
    --enable-gprofng=no \
"

do_configure:prepend:class-target () {
    # fix Can't locate Autom4te/ChannelDefs.pm in @INC (you may need to install the Autom4te::ChannelDefs module) (@INC contains: /build/tmp/work/*/binutils/2.37-r0/recipe-sysroot-native/usr/share/autoconf ...
    # autoconf is installed at buildtool-bar, not build autoconf-native, so need to set autom4te_perllibdir or modify default value in gnu-config
    if [ ! -z "${OPENEULER_NATIVESDK_SYSROOT}" ];then
        export autom4te_perllibdir="${OPENEULER_NATIVESDK_SYSROOT}/usr/share/autoconf"
    fi
}

