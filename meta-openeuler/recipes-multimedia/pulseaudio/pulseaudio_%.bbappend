# main bb: openembedded-core/meta/recipes-multimedia/pulseaudio/pulseaudio_16.1.bb
# from git://git.openembedded.org/openembedded-core

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"

PV = "16.1"

SRC_URI += " \
        file://pulseaudio-${PV}.tar.xz \
        file://0001-Fix-the-problem-that-the-description-field-of-pa_als.patch \
        file://0001-alsa-mixer-avoid-assertion-at-alsa-lib-mixer-API-whe.patch \
        file://0001-alsa-mixer-allow-to-re-attach-the-mixer-control-elem.patch \
        file://0001-idxset-Add-set-contains-function.patch \
        file://0002-idxset-Add-set-comparison-operations.patch \
        file://0003-idxset-Add-reverse-iteration-functions.patch \
        file://0001-alsa-ucm-Always-create-device-conflicting-supported-.patch \
"

S = "${WORKDIR}/pulseaudio-${PV}"

# it is a mobile feature
PACKAGECONFIG:remove = " ofono "

