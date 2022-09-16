# version in src-openEuler
PV = "2.11.0"

# apply src-openEuler patches
SRC_URI_prepend = "file://backport-freetype-2.3.0-enable-spr.patch \
           file://backport-freetype-2.2.1-enable-valid.patch \
           file://backport-freetype-2.6.5-libtool.patch \
           file://backport-freetype-2.8-multilib.patch \
           file://backport-freetype-2.10.0-internal-outline.patch \
           file://backport-freetype-2.10.1-debughook.patch \
           file://backport-CVE-2022-27404.patch \
           file://backport-0001-CVE-2022-27405.patch \
           file://backport-0002-CVE-2022-27405.patch \
           file://backport-CVE-2022-27406.patch \
           "

# LICENSE.TXT change
LIC_FILES_CHKSUM_remove = "file://docs/LICENSE.TXT;md5=4af6221506f202774ef74f64932878a1 \
"
LIC_FILES_CHKSUM_prepend = "file://LICENSE.TXT;md5=a5927784d823d443c6cae55701d01553 \
"

# new checksum
SRC_URI[sha256sum] = "8bee39bd3968c4804b70614a0a3ad597299ad0e824bc8aad5ce8aaf48067bde7"
