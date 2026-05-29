FILESEXTRAPATHS:prepend := "${THISDIR}/libselinux:"

# gcompat is only needed on riscv64 musl; ARM musl does not ship libgcompat.so
DEPENDS:append:riscv64 = " gcompat"
DEPENDS += "${@bb.utils.contains('LIBC', 'musl', 'fts', '', d)}"

# malloc_trim() is a glibc extension; guard it so libselinux builds with musl.
SRC_URI:append = " file://0001-musl-guard-malloc_trim-with-__GLIBC__.patch"

do_configure:prepend () {
    if  ! grep -q "-lfts" ${S}/src/Makefile ; then  sed -i 's/FTS_LDLIBS ?=/FTS_LDLIBS ?= -lfts/' ${S}/src/Makefile; fi

    if [ "${TARGET_ARCH}" = "riscv64" ]; then
        if  ! grep -q "MU_LDLIBS" ${S}/src/Makefile; then
            sed -i '/FTS_LDLIBS ?=/aMU_LDLIBS ?= -lgcompat' ${S}/src/Makefile
            sed -i 's/$(FTS_LDLIBS)/$(FTS_LDLIBS) $(MU_LDLIBS)/' ${S}/src/Makefile;
        fi
    fi
    sed -i '/.*FTS_LDLIBS*/c\override LDLIBS += -lselinux -lfts '  ${S}/utils/Makefile
}
