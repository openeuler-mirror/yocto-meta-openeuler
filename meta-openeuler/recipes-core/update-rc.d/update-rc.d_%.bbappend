# main bbfile: yocto-poky/meta/recipes-core/update-rc.d/update-rc.d_0.8.bb

# update-rc.d does not require code download, to avoid the conflict of update-rc.d folder
# (set by DL_DIR ?= "${OPENEULER_SP_DIR}/${BPN}" )
# and update-rc.d script file (with update-rc.d_0.8.bb ),
OPENEULER_REPO_NAME = "update-rc.d_dummy"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://update-rc.d"

SRC_URI[sha256sum] = "5426fe8d447719957b51bdce842fb857816a6d5cd5053f7586ffbf66b48111d2"

S = "${WORKDIR}"
