# src verion is in yocto-pseudo repo
OPENEULER_LOCAL_NAME = "yocto-pseudo"

SRC_URI:prepend = "file://${BP}.tar.gz "

# pseudo >= 1.9.10 prunes PIE flags in configure itself, the poky patch no
# longer applies and is not needed anymore.
SRC_URI:remove = "file://0001-configure-Prune-PIE-flags.patch"

# The prebuilt libpseudo and its symbol patch exist for running pseudo on
# hosts with older glibc. With nativesdk/prebuilt host tools removed the
# build container glibc is used everywhere, and the patch does not apply to
# the updated source anyway.
SRC_URI:remove:class-native = "file://older-glibc-symbols.patch"
SRC_URI:remove:class-native = "http://downloads.yoctoproject.org/mirror/sources/pseudo-prebuilt-2.33.tar.xz;subdir=git/prebuilt;name=prebuilt"
SRC_URI:remove:class-nativesdk = "file://older-glibc-symbols.patch"
SRC_URI:remove:class-nativesdk = "http://downloads.yoctoproject.org/mirror/sources/pseudo-prebuilt-2.33.tar.xz;subdir=git/prebuilt;name=prebuilt"

# pseudo 1.9.11 (adds openat2 wrapping required by GNU tar >= 1.35)
PV = "ba8887e5f1e922f866681ec7dec1a00b602a9328"
S = "${WORKDIR}/${BP}"
