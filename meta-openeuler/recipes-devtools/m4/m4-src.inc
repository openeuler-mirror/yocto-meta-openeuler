OPENEULER_SRC_URI_REMOVE = "https"

PV = "1.4.19"

# append files and patches from openeuler
SRC_URI:append = " \
    file://m4-${PV}.tar.xz \
    file://0001-Delete-test-execute_sh.patch \
"
