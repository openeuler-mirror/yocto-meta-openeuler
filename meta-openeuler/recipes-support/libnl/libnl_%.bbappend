# the main bb file: yocto-poky/meta/recipes-support/libnl/

OPENEULER_REPO_NAME = "libnl3"

PV = "3.7.0"

SRC_URI:remove = " \
    https://github.com/thom311/${BPN}/releases/download/${BPN}${@d.getVar('PV').replace('.','_')}/${BP}.tar.g \
    file://enable-serial-tests.patch \
"

SRC_URI:append = "\
    file://libnl-3.7.0.tar.gz \
"

SRC_URI[md5sum] = "b381405afd14e466e35d29a112480333"
SRC_URI[sha256sum] = "9fe43ccbeeea72c653bdcf8c93332583135cda46a79507bfd0a483bb57f65939"
