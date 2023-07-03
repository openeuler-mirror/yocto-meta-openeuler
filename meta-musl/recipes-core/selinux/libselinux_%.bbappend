DEPENDS:append = " gcompat "
DEPENDS += "${@bb.utils.contains('LIBC', 'musl', 'fts', '', d)}"

do_configure:prepend () {
    if  ! grep -q "-lfts" ${S}/src/Makefile ; then  sed -i 's/FTS_LDLIBS ?=/FTS_LDLIBS ?= -lfts/' ${S}/src/Makefile; fi

    if  ! grep -q "MU_LDLIBS" ${S}/src/Makefile; then
        sed -i '/FTS_LDLIBS ?=/aMU_LDLIBS ?= -lgcompat' ${S}/src/Makefile
        sed -i 's/$(FTS_LDLIBS)/$(FTS_LDLIBS) $(MU_LDLIBS)/' ${S}/src/Makefile;
    fi
    sed -i '/.*FTS_LDLIBS*/c\override LDLIBS += -lselinux -lfts '  ${S}/utils/Makefile
}
