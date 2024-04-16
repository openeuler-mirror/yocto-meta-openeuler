PV = "1.2.8"

SRC_URI:prepend = " \
        file://${BP}.tar.bz2 \
        file://alsa-utils-git.patch \
"

SRC_URI[sha256sum] = "ac5b2a1275783eff07e1cb34c36c6c5987742679a340037507c04a9dc1d22cac"

