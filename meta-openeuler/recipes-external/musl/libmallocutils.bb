SUMMARY = "mallopt and malloc_trim for musl"
LICENSE="CLOSED"
LIC_FILES_CHKSUM=""
SECTION = "libs"

SRC_URI = "   \
    file://malloc_utils.c      \
    file://malloc_utils.h      \
"

DEPENDS = "virtual/${TARGET_PREFIX}binutils \
           virtual/${TARGET_PREFIX}gcc \
"

do_configure[noexec] = "1"

S = "${WORKDIR}"

do_compile() {
        ${CC} -fpic -O2 malloc_utils.c -c -o malloc_utils.So
        ${CC} -shared -Wl,-soname,libmallocutils.so.1 -o libmallocutils.so.1 malloc_utils.So 

        ${CC} -O2 -c malloc_utils.c 
        ${AR} rcs libmallocutils.a malloc_utils.o
}

do_install() {
        install -D -m755 libmallocutils.so.1 ${D}${libdir}/libmallocutils.so.1
        install -D -m644 libmallocutils.a ${D}${libdir}/libmallocutils.a
        install -D -m644 malloc_utils.h ${D}${includedir}/malloc_utils.h
}

#
# We will skip parsing for non-musl systems
#
COMPATIBLE_HOST = ".*-musl.*"
