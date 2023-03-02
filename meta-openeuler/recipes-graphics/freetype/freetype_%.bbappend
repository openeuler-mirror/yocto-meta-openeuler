# version in src-openEuler
OPENEULER_BRANCH = "openEuler-23.03"
PV = "2.12.1"

# apply src-openEuler patches
# backport-freetype-2.5.2-more-demos.patch for ft2demos
SRC_URI_prepend = "file://backport-freetype-2.3.0-enable-spr.patch \
           file://backport-freetype-2.2.1-enable-valid.patch \
           file://backport-freetype-2.6.5-libtool.patch \
           file://backport-freetype-2.8-multilib.patch \
           file://backport-freetype-2.10.0-internal-outline.patch \
           file://backport-freetype-2.10.1-debughook.patch \
           "

# LICENSE.TXT change
LIC_FILES_CHKSUM_remove = "file://docs/LICENSE.TXT;md5=4af6221506f202774ef74f64932878a1 \
"
LIC_FILES_CHKSUM_prepend = "file://LICENSE.TXT;md5=a5927784d823d443c6cae55701d01553 \
"

# new checksum
SRC_URI[sha256sum] = "4766f20157cc4cf0cd292f80bf917f92d1c439b243ac3018debf6b9140c41a7f"
