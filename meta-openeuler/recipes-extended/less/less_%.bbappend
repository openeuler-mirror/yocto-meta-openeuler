# main bbfile: yocto-poky/meta/recipes-extended/less/less_563.bb

# less version in openEuler
PV = "608"

LIC_FILES_CHKSUM = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464 \
                    file://LICENSE;md5=38fc26d78ca8d284a2a5a4bbc263d29b \
                    "

# Use the source packages and patches from openEuler
# less-475-fsync.patch can't apply: cannot run test program while cross compiling
SRC_URI = "file://${BP}.tar.gz \
            file://less-394-time.patch \
            file://backport-End-OSC8-hyperlink-on-invalid-embedded-escape-sequen.patch \
            "

SRC_URI[md5sum] = "1cdec714569d830a68f4cff11203cdba"
SRC_URI[sha256sum] = "a69abe2e0a126777e021d3b73aa3222e1b261f10e64624d41ec079685a6ac209"
