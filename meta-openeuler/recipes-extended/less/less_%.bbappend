# main bbfile: yocto-poky/meta/recipes-extended/less/less_563.bb

# less version in openEuler
PV = "692"

LIC_FILES_CHKSUM = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464 \
                    file://LICENSE;md5=bee5763a5e2bccdcdbd9bfe982ffc82b \
                    "

# Use the source packages and patches from openEuler
# less-475-fsync.patch can't apply: cannot run test program while cross compiling
SRC_URI = "file://${BP}.tar.gz \
            file://less-394-time.patch \
            "


SRC_URI[md5sum] = "1cdec714569d830a68f4cff11203cdba"
SRC_URI[sha256sum] = "a69abe2e0a126777e021d3b73aa3222e1b261f10e64624d41ec079685a6ac209"

ASSUME_PROVIDE_PKGS = "less"
