# new ref upstream: openembedded-core/meta/recipes-multimedia/ffmpeg/ffmpeg_6.1.1.bb

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "6.1.1"

# source change to openEuler
SRC_URI:prepend = "file://${BP}.tar.xz \
        file://avformat-get_first_dts.patch \
        file://0001-fix-CVE-2024-31578.patch \
        file://0002-fix-CVE-2024-31582.patch \
        "                             

# x264 need LICENSE_FLAGS_ACCEPTED commercial flag 
# OSV notice: Please consider GPL contamination when releasing
PACKAGECONFIG:append = "${@bb.utils.contains('LICENSE_FLAGS_ACCEPTED', 'commercial', ' gpl x264 ', '', d)}"
