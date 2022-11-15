SUMMARY = "libexecinfo for musl"
LICENSE="CLOSED"
LIC_FILES_CHKSUM=""
SECTION = "libs"

SRC_URI = " \
    file://execinfo.c \
    file://execinfo.h \
"

DEPENDS = "virtual/${TARGET_PREFIX}binutils \
           virtual/${TARGET_PREFIX}gcc \
"

do_configure[noexec] = "1"

S = "${WORKDIR}"

do_compile() {
        ${CC} -fpic -O2 -Wno-frame-address -Wno-unused-parameter -std=c99 -c execinfo.c -o execinfo.So
        ${CC} -shared -Wl,-soname,libexecinfo.so.1 -o libexecinfo.so.1 execinfo.So

        ${CC} -O2 -Wno-frame-address -Wno-unused-parameter -std=c99 -c execinfo.c
        ${AR} rcs libexecinfo.a execinfo.o
}
do_install() {
        install -D -m755 libexecinfo.so.1 ${D}${libdir}/libexecinfo.so.1
        install -D -m644 libexecinfo.a ${D}${libdir}/libexecinfo.a
        install -D -m644 execinfo.h ${D}${includedir}/execinfo.h
}

#
# We will skip parsing for non-musl systems
#
COMPATIBLE_HOST = ".*-musl.*"
