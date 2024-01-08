# this image refers yocto's core-image-rt.bb
require recipes-core/images/openeuler-image-tiny.bb

# Skip processing of this recipe if linux-openeuler-rt is not explicitly specified as the
# PREFERRED_PROVIDER for virtual/kernel. This avoids errors when trying
# to build multiple virtual/kernel providers.
python () {
    if d.getVar("PREFERRED_PROVIDER_virtual/kernel") != "linux-openeuler-rt":
        raise bb.parse.SkipRecipe("Set PREFERRED_PROVIDER_virtual/kernel to linux-openeuler-rt to enable it")
}

DESCRIPTION = "A small image just capable of allowing a device to boot plus a \
real-time test suite and tools appropriate for real-time use."
DEPENDS += "linux-openeuler-rt"

IMAGE_INSTALL += "rt-tests hwlatdetect"

LICENSE = "MIT"
