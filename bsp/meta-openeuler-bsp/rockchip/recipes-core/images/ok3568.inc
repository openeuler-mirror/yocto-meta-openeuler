#image configuration for aarch64
require rk3568.inc

IMAGE_INSTALL:remove = " \
packagegroup-core-base-utils \
"
