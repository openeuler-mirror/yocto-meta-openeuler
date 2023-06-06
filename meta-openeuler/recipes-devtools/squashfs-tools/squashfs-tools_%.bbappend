# main bbfile: yocto-poky/meta/recipes-devtools/squashfs-tools/squashfs-tools_git.bb

# version in openEuler
PV = "4.5"

FILESEXTRAPATHS_append := "${THISDIR}/files/:"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI = ""

S = "${WORKDIR}/${BP}/${BPN}"

# files, patches that come from openeuler
# 0001-Avoid-use-of-INSTALL_DIR-for-symlink-targets.patch: \
# from https://github.com/plougher/squashfs-tools/commit/f5c908e92d4c055859be2fddbda266d9e3bfd415
SRC_URI =+ " \
        file://squashfs${PV}.tar.gz \
        file://0001-CVE-2021-41072.patch;striplevel=2 \
        file://0002-CVE-2021-41072.patch;striplevel=2 \
        file://0003-CVE-2021-41072.patch;striplevel=2 \
        file://0004-CVE-2021-41072.patch;striplevel=2 \
        file://0005-CVE-2021-41072.patch;striplevel=2 \
        file://0001-Avoid-use-of-INSTALL_DIR-for-symlink-targets.patch;striplevel=2 \
        file://0006-pseudo-fix-possible-dereference-of-NULL-pointer.patch;striplevel=2 \
        "
