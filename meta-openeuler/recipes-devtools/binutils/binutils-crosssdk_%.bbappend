require binutils-src.inc

# Keeps up with the current gcc recipe of meta-openeuler.
# We need to specify gcc-crosssdk because we haven't synchronized the upstream gcc recipes yet.
# Provide both names:
# - virtual/${TARGET_PREFIX}binutils-crosssdk : used by gcc-crosssdk / gcc-cross-canadian recipes in this layer
# - virtual/${TARGET_PREFIX}binutils           : standard scarthgap name expected by nativesdk-qemuwrapper-cross and tcmode-default
PROVIDES = "virtual/${TARGET_PREFIX}binutils-crosssdk virtual/${TARGET_PREFIX}binutils"
