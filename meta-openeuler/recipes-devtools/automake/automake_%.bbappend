PV = "1.16.5"

SRC_URI:prepend = "file://${BP}.tar.xz \
"

# These patches were written for automake 1.17; they do not apply to 1.16.5
SRC_URI:remove = "file://0002-automake-Update-for-python.m4-to-respect-libdir.patch \
                  file://0006-automake-Remove-delays-in-configure-scripts-using-au.patch"

SRC_URI[sha256sum] = "8920c1fc411e13b90bf704ef9db6f29d540e76d232cb3b2c9f4dc4cc599bd990"
