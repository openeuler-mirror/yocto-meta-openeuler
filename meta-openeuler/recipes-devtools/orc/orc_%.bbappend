# the main bb file: yocto-poky/meta/recipes-devtools/orc/orc_0.4.32.bb

PV = "0.4.34"

SRC_URI = "file://${BP}.tar.xz \
      file://backport-0001-CVE-2024-40897.patch \
      file://backport-0002-CVE-2024-40897.patch \
      file://backport-Fix-warning-because-of-a-mismatched-OrcExecutor-function-signature.patch \
      file://backport-Fix-binutils-warning-when-comparing-with-sized-immediate-operand.patch \
      file://backport-Fix-default-target-selection-not-applying-when-retrieving-it-by-name.patch \
"

SRC_URI[sha256sum] = "844e6d7db8086f793f57618d3d4b68d29d99b16034e71430df3c21cfd3c3542a"
