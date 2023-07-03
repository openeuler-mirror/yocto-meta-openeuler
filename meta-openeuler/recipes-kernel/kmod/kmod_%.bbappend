# main bbfile: yocto-poky/meta/recipes-kernel/kmod/kmod_git.bb

# kmod version in openEuler
PV = "30"

# Use the source packages from openEuler
SRC_URI:remove = "git://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git \
        git://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git;branch=master \
        file://0001-depmod-Add-support-for-excluding-a-directory.patch \
        "
SRC_URI:prepend = "file://${BP}.tar.xz \
        file://0001-Module-replace-the-module-with-new-module.patch \
        file://0002-Module-suspend-the-module-by-rmmod-r-option.patch \
        "

SRC_URI[md5sum] = "85202f0740a75eb52f2163c776f9b564"
SRC_URI[sha256sum] = "f897dd72698dc6ac1ef03255cd0a5734ad932318e4adbaebc7338ef2f5202f9f"

# yocto-poky specifies 'S = "${WORKDIR}/git', but since we are using the openeuler package,
# we need to re-specify it
S = "${WORKDIR}/${BP}"
