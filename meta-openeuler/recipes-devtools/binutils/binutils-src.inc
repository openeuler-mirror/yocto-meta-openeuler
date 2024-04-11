PV = "2.41"
S = "${WORKDIR}/${BP}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# apply package source and patches from openeuler
SRC_URI = " \
    file://${BP}.tar.xz \
    file://X86-Change-fpic-to-fPIC-in-PICFLAG.patch \
    file://binutils-libtool-lib64.patch \
    file://binutils-export-demangle.h.patch \
    file://binutils-no-config-h-check.patch \
    file://binutils-2.27-aarch64-ifunc.patch \
    file://binutils-special-sections-in-groups.patch \
    file://binutils-gold-mismatched-section-flags.patch \
    file://binutils-update-linker-manual.patch \
    file://binutils-gold-empty-dwp.patch \
"

# apply used patches from poky
SRC_URI += " \
    file://0005-Point-scripts-location-to-libdir.patch \
"

SRC_URI[sha256sum] = "ae9a5789e23459e59606e6714723f2d3ffc31c03174191ef0d015bdf06007450"

# openeuler configuration
# We do not need gprofng now, if required, enable it in the future
EXTRA_OECONF:append = " \
    --enable-gprofng=no \
"
GPROFNGS = ""

do_configure:prepend:class-target () {
    # fix Can't locate Autom4te/ChannelDefs.pm in @INC (you may need to install the Autom4te::ChannelDefs module) (@INC contains: /build/tmp/work/*/binutils/2.37-r0/recipe-sysroot-native/usr/share/autoconf ...
    # autoconf is installed at buildtool-bar, not build autoconf-native, so need to set autom4te_perllibdir or modify default value in gnu-config
    if [ "${OPENEULER_PREBUILT_TOOLS_ENABLE}" = "yes" ] && [ ! -z "${OPENEULER_NATIVESDK_SYSROOT}" ];then
        export autom4te_perllibdir="${OPENEULER_NATIVESDK_SYSROOT}/usr/share/autoconf"
    fi
}
