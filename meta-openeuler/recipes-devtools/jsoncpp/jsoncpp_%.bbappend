# main bb: yocto-meta-openembedded/meta-oe/recipes-devtools/jsoncpp/jsoncpp_1.9.5.bb

PV = "1.9.5"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://0001-Parse-large-floats-as-infinity-1349-1353.patch \
    file://0001-Use-default-rather-than-hard-coded-8-for-maximum-agg.patch \
"

S = "${WORKDIR}/${BP}"

