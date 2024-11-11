# main bb: meta-wayland/recipes-extended/font-awesome/font-awesome-otf_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

inherit oee-archive

LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=9b9d97c72a232b7715f2aed4bf4a4d45"

PV = "6.5.2"

SRC_URI:prepend = " \
        file://${PV}.tar.gz \
"

S = "${WORKDIR}/Font-Awesome-${PV}"
