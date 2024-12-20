# new ref upstream: openembedded-core/meta/recipes-multimedia/ffmpeg/ffmpeg_6.1.1.bb

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "6.1.1"

# source change to openEuler
SRC_URI:prepend = "file://${BP}.tar.xz \
        file://avformat-get_first_dts.patch \
        file://fix-CVE-2023-50007.patch \
        file://fix-CVE-2023-50008.patch \
        file://fix-CVE-2024-31578.patch \
        file://fix-CVE-2024-31582.patch \
        file://fix_libsvgdec_compile_error.patch \
        file://CVE-2023-49528.patch \
        file://fix-CVE-2023-49502.patch \
        file://fix-CVE-2024-32230.patch \
        file://CVE-2024-7055.patch \
        file://CVE-2023-49501.patch \
        file://backport-CVE-2024-35366.patch \
        file://backport-CVE-2024-35367.patch \
        "                             

# x264 and some pkgconfig need LICENSE_FLAGS_ACCEPTED commercial flag 
# OSV notice: Please consider GPL contamination when releasing
PACKAGECONFIG:append = "${@bb.utils.contains('LICENSE_FLAGS_ACCEPTED', 'commercial', ' gpl x264 ', '', d)}"

# sync non GPL pkgconfig and remove LICENSE_FLAGS commercial from openuelr
# ref: src-openeuler/ffmpeg/ffmpeg.spec
# %global _without_cdio    1
# %global _without_frei0r  1
# %global _without_gpl     1
# %global _without_vidstab 1
# %global _without_x264    1
# %global _without_x265    1
# %global _without_xvid    1
LICENSE_FLAGS:remove = "commercial"
PACKAGECONFIG:append = " vpx theora v4l2 "
