# main bbfile ref: 
# https://git.openembedded.org/meta-openembedded/tree/meta-networking/recipes-connectivity/mosquitto/mosquitto_2.0.18.bb?h=master

PV = "2.0.16"

SRC_URI:append = " \
        file://${BP}.tar.gz \
        file://add-usage-output.patch \
        file://fix-usage-exit-code.patch \
"

BBCLASSEXTEND += "native nativesdk"
