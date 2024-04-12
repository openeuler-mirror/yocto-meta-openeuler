require binutils-src.inc

# Keeps up with the current gcc recipe of meta-openeuler.
# We need to specify gcc-crosssdk because we haven't synchronised the upstream gcc recipes yet.
DEPENDS = "flex-native bison-native virtual/${HOST_PREFIX}gcc-crosssdk virtual/nativesdk-libc nativesdk-zlib nativesdk-gettext nativesdk-flex"
