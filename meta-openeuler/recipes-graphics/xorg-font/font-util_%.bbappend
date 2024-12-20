require openeuler-xorg-font-common.inc

OPENEULER_LOCAL_NAME = "xorg-x11-font-utils"

PV = "1.3.2"

SRC_URI:remove = " \
  file://0001-mkfontscale-examine-all-encodings.patch \
"
SRC_URI:append = " \
  file://0001-mkfontscale-examine-all-encodings.patch \
"
