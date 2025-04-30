PV = "0.6.0"

inherit oee-archive

SRC_URI[sha256sum] = "b4df8cf5a649ff6f25cb885a7a93662f38229e05f1859db663f752a6203014f6"

# upstream source
SRC_URI:prepend = " \
            file://installer-${PV}.tar.gz  \
           "
