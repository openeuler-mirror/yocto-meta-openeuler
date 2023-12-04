require openeuler-xorg-app-common.inc

OPENEULER_REPO_NAME = "xorg-x11-font-utils"

PV = "1.1.3"

LIC_FILES_CHKSUM = "file://COPYING;md5=2e0d129d05305176d1a790e0ac1acb7f"

# version 1.1.3 hasn't provide mkfontdir, see meta-openeuler/recipes-graphics/xorg-app/mkfontdir_1.0.7.bb
PROVIDES:remove = "mkfontdir"
RPROVIDES:${PN}:remove = "mkfontdir"
