# main bb: openembedded-core/meta/recipes-multimedia/pulseaudio/pulseaudio_16.1.bb
# from git://git.openembedded.org/openembedded-core

PV = "17.0"

SRC_URI += " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"

# it is a mobile feature
PACKAGECONFIG:remove = " ofono "
