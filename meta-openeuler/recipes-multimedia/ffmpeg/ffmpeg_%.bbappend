# new ref upstream: openembedded-core/meta/recipes-multimedia/ffmpeg/ffmpeg_6.1.1.bb

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "6.1.6"

# source change to openEuler
SRC_URI:prepend = "file://${BP}.tar.xz \
        file://avformat-get_first_dts.patch \
        file://CVE-2023-49528.patch \
        file://backport-CVE-2024-35369.patch \
        file://CVE-2025-25473.patch \
        file://backport-CVE-2026-64830.patch \
        file://backport-CVE-2026-64835.patch \
        file://backport-CVE-2026-64831.patch \
        file://backport-CVE-2026-64832.patch \
        file://backport-CVE-2026-64833.patch \
        file://backport-CVE-2026-64834.patch \
        file://backport-CVE-2026-65703.patch \
        file://backport-CVE-2026-65704.patch \
        file://backport-CVE-2026-65705.patch \
        file://backport-CVE-2026-65706.patch \
        file://backport-CVE-2026-70629.patch \
        file://CVE-2026-58049.patch \
        file://CVE-2026-70630.patch \
        file://fix-CVE-2026-75141.patch \
        file://fix-CVE-2026-75142.patch \
        file://fix-CVE-2026-75143.patch \
        file://fix-CVE-2026-75144.patch \
        file://fix-CVE-2026-75146.patch \
        file://CVE-2026-30998.patch \
        file://fix-CVE-2026-66036.patch \
        file://fix-CVE-2026-66038.patch \
        file://fix-CVE-2026-66039.patch \
        file://fix-CVE-2026-70628.patch \
        file://fix-CVE-2026-70631.patch \
        file://fix-CVE-2026-70632.patch \
        file://backport-libavcodec-riscv-add-RVV-optimized-hevc_add_res.patch \
        file://backport-CVE-2026-107677.patch \
        file://backport-CVE-2026-107676.patch \
        file://backport-CVE-2026-107695.patch \
        file://backport-CVE-2026-107660.patch \
        file://backport-CVE-2026-107675.patch \
        file://backport-CVE-2026-107697.patch \
        file://backport-CVE-2026-107696.patch \
        file://backport-CVE-2026-13858.patch \
        "                             

# x264 and some pkgconfig need LICENSE_FLAGS_ACCEPTED commercial flag 
# OSV notice: Please consider GPL contamination when releasing
PACKAGECONFIG:append = "${@bb.utils.contains('LICENSE_FLAGS_ACCEPTED', 'commercial', ' gpl x264 x265 ', '', d)}"

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
