# the main bb file: yocto-poky/meta/recipes-support/libnl/

PV = "3.7.0"

SRC_URI:remove = "file://enable-serial-tests.patch \
"

SRC_URI:prepend = "file://${BP}.tar.gz \
           file://backport-prevent-segfault-in-af_request_type.patch \
           file://backport-fix-bridge-info-parsing.patch \
"

SRC_URI[md5sum] = "b381405afd14e466e35d29a112480333"
SRC_URI[sha256sum] = "9fe43ccbeeea72c653bdcf8c93332583135cda46a79507bfd0a483bb57f65939"
