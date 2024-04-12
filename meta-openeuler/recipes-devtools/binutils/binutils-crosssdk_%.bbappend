require binutils-src.inc

# Keeps up with the current gcc recipe of meta-openeuler.
# We need to specify gcc-crosssdk because we haven't synchronised the upstream gcc recipes yet.
PROVIDES = "virtual/${TARGET_PREFIX}binutils-crosssdk"
