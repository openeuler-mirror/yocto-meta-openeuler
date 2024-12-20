# openeuler's unzip repos has patches with the same name of patches in poky,
# so use a workaround here to let poky's path has a higher priority than openeuler's path
# the recommended way is: do not use the same name
OPENEULER_DL_DIR = ""
FILESPATH:append = ":${OPENEULER_SP_DIR}/${OPENEULER_LOCAL_NAME}"
SRC_URI:prepend = " file://unzip60.tar.gz \
  file://0001-Fix-CVE-2016-9844-rhbz-1404283.patch \
  file://unzip-6.0-timestamp.patch \
  file://unzip-6.0-cve-2018-1000035-heap-based-overflow.patch \
  file://unzip-6.0-support-clang-build.patch \
  file://CVE-2019-13232-pre.patch \
"

# unapplicable openeuler patches:
# file://CVE-2018-18384.patch 