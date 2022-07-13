# main bbfile: yocto-poky/meta/recipes-kernel/kern-tools/kern-tools-native_git.bb

# source from from yocto-embedded-tools
SRC_URI = "file://yocto-embedded-tools/build_tools/yocto-kernel-tools"
PV = "0.2"

S = "${WORKDIR}/yocto-embedded-tools/build_tools/yocto-kernel-tools"
