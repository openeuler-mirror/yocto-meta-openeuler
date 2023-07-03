# main bbfile ref: http://cgit.openembedded.org/meta-openembedded/tree/meta-networking/recipes-connectivity/mosquitto?h=zeus

PV = "1.6.15"

SRC_URI:remove = " \
        http://mosquitto.org/files/source/mosquitto-${PV}.tar.gz \
"

SRC_URI:append = " \
        file://mosquitto-${PV}.tar.gz \
        file://add-usage-output.patch \
        file://fix-usage-exit-code.patch \
        file://CVE-2021-41039.patch \
        file://CVE-2021-34432.patch \
"

SRC_URI[md5sum] = "792bdd8fce3a8a1db102988ef6a9a02f"
SRC_URI[sha256sum] = "5ff2271512f745bf1a451072cd3768a5daed71e90c5179fae12b049d6c02aa0f"

BBCLASSEXTEND += "native nativesdk"
