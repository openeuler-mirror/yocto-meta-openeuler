SRC_URI = " \
        ${GNUPG_MIRROR}/npth/npth-${PV}.tar.bz2 \
        file://backport-0001-w32-Use-cast-by-uintptr_t-for-thread-ID.patch \
        file://add-test-cases.patch \
        file://backport-0002-posix-Add-npth_poll-npth_ppoll.patch \
        "

# patches from poky
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
           file://pkgconfig.patch \
           file://0001-Revert-Fix-problem-with-regression-tests-on-recent-g.patch \
          "


SRC_URI[md5sum] = "375d1a15ad969f32d25f1a7630929854"
SRC_URI[sha256sum] = "1393abd9adcf0762d34798dc34fdcf4d0d22a8410721e76f1e3afcd1daa4e2d1"
