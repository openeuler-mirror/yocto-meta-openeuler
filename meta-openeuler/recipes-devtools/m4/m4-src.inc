
PV = "1.4.19"

# append files and patches from openeuler
# don't need 0001-Delete-test-execute_sh.patch for it will need dependency to automake,
# causing a dependency circle to be generated
SRC_URI:append = " \
    file://m4-${PV}.tar.xz \
"
