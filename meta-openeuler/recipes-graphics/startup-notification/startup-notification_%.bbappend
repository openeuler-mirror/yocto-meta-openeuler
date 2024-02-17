# main bb: yocto-poky/meta/recipes-graphics/startup-notification/startup-notification_0.12.bb

PV = "0.12"

SRC_URI += " \
        file://${BP}.tar.gz \
"

S = "${WORKDIR}/${BP}"
