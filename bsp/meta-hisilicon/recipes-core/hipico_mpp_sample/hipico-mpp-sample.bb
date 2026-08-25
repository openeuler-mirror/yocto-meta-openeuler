SUMMARY = "hipico mpp sample"
DESCRIPTION = "mpp samples for hipico"
HOMEPAGE = "https://gitee.com/hieuler-pico/hi_mpp_sample"
LICENSE = "CLOSED"

inherit pkgconfig

OPENEULER_LOCAL_NAME = "hipico_mpp_sample"

SRC_URI = " \
        file://hipico_mpp_sample \
"

S = "${WORKDIR}"

do_compile:prepend () {
    rm -rf ${S}/hipico_mpp_sample/bin
}

TARGET_CC_ARCH += "${LDFLAGS}"
# Makefile does not support the use of the CC environment variable,
# so use make CC="${CC}"
EXTRA_OEMAKE += 'CC="${CC}"'

# workaround to fix error:
# `undefined reference to `vtable for __cxxabiv1::__class_type_info'`
LDFLAGS:remove = "-Wl,--as-needed"

do_compile () {
    pushd ${S}/hipico_mpp_sample
    oe_runmake
    popd
}

do_install () {
    install -d ${D}/root/
	install -d ${D}/lib/

	cp ${S}/hipico_mpp_sample/lib/libsecurec.so ${D}/lib/libsecurec.so.1.0 
    cp ${S}/hipico_mpp_sample/lib/libmp3_enc.so ${D}/lib/libmp3_enc.so.1.0 
    cp ${S}/hipico_mpp_sample/lib/libmp3_lame.so ${D}/lib/libmp3_lame.so.1.0 
    cp ${S}/hipico_mpp_sample/lib/libmp3_dec.so ${D}/lib/libmp3_dec.so.1.0
    cp ${S}/hipico_mpp_sample/lib/libsvp_aicpu.so ${D}/lib/libsvp_aicpu.so.1.0
	
	cp ${S}/hipico_mpp_sample/bin/* ${D}/root/
}

FILES_${PN}-dev += "${libdir}/libsecurec.so ${libdir}/libsecurec.so.1.0"
FILES_${PN}-dev += "${libdir}/libmp3_enc.so ${libdir}/libmp3_enc.so.1.0"
FILES_${PN}-dev += "${libdir}/libmp3_lame.so ${libdir}/libmp3_lame.so.1.0"
FILES_${PN}-dev += "${libdir}/libmp3_dec.so ${libdir}/libmp3_dec.so.1.0"
FILES_${PN}-dev += "${libdir}/libsvp_aicpu.so ${libdir}/libsvp_aicpu.so.1.0"

FILES:${PN} = " \
    /root/ \
	/lib/ \
"

INSANE_SKIP:${PN} += "already-stripped file-rdeps"

# hipico-mpp-sample ships pre-built vendor binaries and their bundled
# .so files in the same package. The binaries NEEDED libsecurec.so etc.
# but the package only ships libsecurec.so.1.0 (no .so symlink). The
# auto-generated RPM Requires(libsecurec.so) have no providers in
# oe-repo, so do_rootfs (dnf) fails. SKIP_FILEDEPS disables per-file
# dependency generation so the RPM doesn't carry those Requires.
SKIP_FILEDEPS = "1"