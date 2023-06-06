# main bbfile: yocto-poky/meta/recipes-extended/less/less_563.bb

# less version in openEuler
PV = "590"

LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504 \
                    file://LICENSE;md5=ba01d0cab7f62f7f2204c7780ff6a87d \
                    "

# Use the source packages and patches from openEuler
# less-475-fsync.patch can't apply: cannot run test program while cross compiling
SRC_URI_remove = "file://less-475-fsync.patch"

SRC_URI_prepend = "file://less-394-time.patch \
            file://backport-Fix-memory-leak-when-using-corrupt-lesshst-file.patch \
            file://backport-Fix-crash-when-enter-invaid-pattern-in-command.patch \
            file://backport-End-OSC8-hyperlink-on-invalid-embedded-escape-sequen.patch \
            "

SRC_URI[md5sum] = "f029087448357812fba450091a1172ab"
SRC_URI[sha256sum] = "6aadf54be8bf57d0e2999a3c5d67b1de63808bb90deb8f77b028eafae3a08e10"
