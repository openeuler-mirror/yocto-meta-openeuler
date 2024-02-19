# main bbfile: yocto-meta-openembedded/meta-oe/recipes-crypto/libsodium/libsodium_1.0.18.bb


SRC_URI:append = " \
        file://${BP}.tar.gz \
"

SRC_URI[md5sum] = "3ca9ebc13b6b4735acae0a6a4c4f9a95"
SRC_URI[sha256sum] = "6f504490b342a4f8a4c4a02fc9b866cbef8622d5df4e5452b46be121e46636c1"

S = "${WORKDIR}/${BP}"
