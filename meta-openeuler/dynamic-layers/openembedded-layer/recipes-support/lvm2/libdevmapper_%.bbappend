require lvm2-src.inc

DEPENDS += "autoconf-archive-native util-linux"

TARGET_CC_ARCH += "${LDFLAGS}"

do_install() {
    oe_runmake 'DESTDIR=${D}' -C libdm install
}

# Do not generate package libdevmapper
PACKAGES = ""

BBCLASSEXTEND = "native nativesdk"
