# main bbfile ref: 
# https://git.openembedded.org/meta-openembedded/tree/meta-networking/recipes-connectivity/mosquitto/mosquitto_2.0.18.bb?h=master

PV = "2.0.20"

# 1571.patch and 2894.patch are included in the source since v2.0.19
# (see meta-openembedded commit "mosquitto: upgrade 2.0.18 -> 2.0.19")
SRC_URI:remove = " \
        file://1571.patch \
        file://2894.patch \
"

SRC_URI:append = " \
        file://${BP}.tar.gz \
        file://add-usage-output.patch \
        file://fix-usage-exit-code.patch \
"

BBCLASSEXTEND += "native nativesdk"
