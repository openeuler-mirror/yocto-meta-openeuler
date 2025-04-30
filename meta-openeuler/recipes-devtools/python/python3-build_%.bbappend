PV = "0.10.0"

inherit oee-archive

SRC_URI[sha256sum] = "248a092b06b97a6377ba457264c86c1925a89bbd225da3b03da0c0d42b90974c"

# upstream source
SRC_URI:prepend = " \
            file://build-${PV}.zip  \
           "
