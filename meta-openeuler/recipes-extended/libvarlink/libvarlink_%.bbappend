# main bb: meta-wayland/recipes-extended/libvarlink/libvarlink_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

LIC_FILES_CHKSUM = "file://LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

PV = "23"

SRC_URI += " \
        file://${BP}.tar.gz \
"

S = "${WORKDIR}/${BP}"

