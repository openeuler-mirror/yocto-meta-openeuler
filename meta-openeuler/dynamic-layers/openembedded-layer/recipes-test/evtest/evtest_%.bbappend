# main bb file: yocto-meta-openembedded/meta-oe/recipes-test/evtest/evtest_1.34.bb

S = "${WORKDIR}/evtest-${BPN}-${PV}"

SRC_URI:remove = "git://gitlab.freedesktop.org/libevdev/evtest.git;protocol=https;branch=master \
                  "
SRC_URI:prepend = "file://evtest-evtest-${PV}.tar.bz2 \
                   "
SRC_URI[sha256sum] = "dd15cea31ff9e654cbc2412ac6da026fedaa3b20ecc529b0ef76f28b0cbd2a40"
