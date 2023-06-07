PV = "3.3"

OPENEULER_SRC_URI_REMOVE = "https git http"
SRC_URI_prepend = "file://${BP}.tar.gz \
        file://backport-libselinux-Close-leaked-FILEs.patch \
        file://backport-libselinux-free-memory-on-selabel_open-3-failure.patch \
        file://backport-libselinux-restorecon-misc-tweaks.patch \
        file://backport-libselinux-free-memory-in-error-branch.patch \
        file://backport-libselinux-restorecon-avoid-printing-NULL-pointer.patch \
        file://do-malloc-trim-after-load-policy.patch \
        "

SRC_URI[md5sum] = "11d0be95e63fbe73a34d1645c5f17e28"
SRC_URI[sha256sum] = "77c294a927e6795c2e98f74b5c3adde9c8839690e9255b767c5fca6acff9b779"

S = "${WORKDIR}/${BP}"
