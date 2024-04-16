FILESEXTRAPATHS:prepend := "${THISDIR}/alsa-plugins/:"
PV = "1.2.7.1"

SRC_URI:prepend = " \
        file://${BP}.tar.bz2 \
        file://0001-arcam_av.c-Include-missing-string.h.patch \
"
# 0001-arcam_av.c-Include-missing-string.h.patch is from openembedded

SRC_URI[sha256sum] = "ac5b2a1275783eff07e1cb34c36c6c5987742679a340037507c04a9dc1d22cac"

