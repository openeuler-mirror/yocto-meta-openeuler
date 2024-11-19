# openeuler's unzip repos has patches with the same name of patches in poky,
# so use a workaround here to let poky's path has a higher priority than openeuler's path
# the recommended way is: do not use the same name
OPENEULER_DL_DIR = ""
FILESPATH:append = ":${OPENEULER_SP_DIR}/${OPENEULER_LOCAL_NAME}"
SRC_URI:prepend = " file://unzip60.tar.gz "
