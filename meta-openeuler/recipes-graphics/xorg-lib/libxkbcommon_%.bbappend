# version in src-openEuler
PV = "1.6.0"

SRC_URI:prepend = " file://${BP}.tar.xz "

SRC_URI[sha256sum] = "0edc14eccdd391514458bc5f5a4b99863ed2d651e4dd761a90abf4f46ef99c2b"

# sync from 1.6.0 bb from openembedded
inherit bash-completion
BBCLASSEXTEND += "native"
CVE_PRODUCT += "xkbcommon:libxkbcommon"

