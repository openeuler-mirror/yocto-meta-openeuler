PV = "3.4.2"

SRC_URI[md5sum] = "294b921e6cf9ab0fbaea4b639f8fdbe8"
SRC_URI[sha256sum] = "540fb721619a6aba3bdeef7d940d8e9e0e6d2c193595bc243241b77ff9e93620"

LIC_FILES_CHKSUM = "file://LICENSE;md5=679b5c9bdc79a2b93ee574e193e7a7bc"

# add not-win32.patch to fix libdir error
SRC_URI = " \
    file://${BPN}-${PV}.tar.gz \
           file://not-win32.patch \
"
