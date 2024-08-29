PV = "1.2.10"

SRC_URI:prepend = " \
        file://${BP}.tar.bz2 \
        file://alsa-utils-git.patch \
"

SRC_URI[sha256sum] = "104b62ec7f02a7ce16ca779f4815616df1cc21933503783a9107b5944f83063a"

