# main bb: meta-wayland/recipes-support/wlr-randr/wlr-randr_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

inherit oee-archive

PV = "0.4.1"

SRC_URI += " \
        file://v${PV}.tar.gz \
"

S = "${WORKDIR}/wlr-randr-v${PV}"
