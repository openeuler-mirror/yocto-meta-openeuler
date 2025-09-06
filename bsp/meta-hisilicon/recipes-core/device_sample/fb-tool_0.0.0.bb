SUMMARY = "hieuler device sample for fb_tool"
DESCRIPTION = "device samples of hieulerpi of fb_tool"
HOMEPAGE = "https://gitee.com/HiEuler/externed_device_sample"
LICENSE = "CLOSED"

inherit pkgconfig

OPENEULER_LOCAL_NAME = "HiEuler-driver"

KN_SUFFIX = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '-6.6', '', d)}"

SRC_URI = " \
        file://HiEuler-driver/drivers${KN_SUFFIX}/ss928_fb_tool \
"

RDEPENDS:${PN} = "hieulerpi1-user-driver"

S = "${WORKDIR}"

do_compile:prepend () {
}

TARGET_CC_ARCH += "${LDFLAGS}"
# Makefile does not support the use of the CC environment variable,
# so use make CC="${CC}"
EXTRA_OEMAKE += 'CC="${CC}"'

# workaround to fix error:
# `undefined reference to `vtable for __cxxabiv1::__class_type_info'`
LDFLAGS:remove = "-Wl,--as-needed"

do_compile () {
    export REL_DIR=${S}/externed_device_sample/mpp/out
    # TODO
}

do_install () {
    install -d ${D}/root/
    install -m 755 ${S}/HiEuler-driver/drivers-6.6/ss928_fb_tool ${D}/root/
}

FILES:${PN} = " \
    /root/ss928_fb_tool \
"

INSANE_SKIP:${PN} += "already-stripped"
