# main bb: https://layers.openembedded.org/layerindex/recipe/332577/

PV = "1.2.2"

SRC_URI:remove = "git://github.com/open62541/open62541.git;protocol=https;branch=${BRANCH} \
"
SRC_URI:prepend = "file://${BPN}-${PV}.tar.gz \
"
SRC_URI[sha256sum] = "9b5bfd811ee523be601f11abc514a93c67fe5c6e957cd6c36fe6ea4f28e009bb"

S = "${WORKDIR}/${BPN}-${PV}"
