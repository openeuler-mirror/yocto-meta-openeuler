SUMMARY = "A small image just capable of openEuler Embedded's airos feature"

require recipes-core/images/openeuler-image-common.inc

# add packagegroup-airos
IMAGE_INSTALL:append = " \
packagegroup-airos \
"