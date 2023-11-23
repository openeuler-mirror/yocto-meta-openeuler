OPENEULER_REPO_NAME = "libnl3"

OPENEULER_SRC_URI_REMOVE = "https"

SRC_URI_prepend = "file://libnl-${PV}.tar.gz \
"

PV = "3.7.0"

SRC_URI[md5sum] = "b381405afd14e466e35d29a112480333"
SRC_URI[sha256sum] = "9fe43ccbeeea72c653bdcf8c93332583135cda46a79507bfd0a483bb57f65939"
