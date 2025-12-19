# This file should be included in openeuler-image.bbappend, openeuler-image-ros.bbappend, etc.
# diff from ${MACHINE}.inc, it should not be included in live image

require recipes-core/images/bsp-${MACHINE}.inc

OEBRIDGE_PIP_LISTS = " \
protobuf>=3.13.0 \
psutil>=5.7.0 \
numpy>=1.13.3 \
scipy>=1.4.1 \
decorator>=4.4.0 \
sympy>=1.5.1 \
cffi>=1.12.3 \
absl-py \
attrs \  
"

IMAGE_INSTALL += " libyaml elfutils sqlite3 "

# add kernel-module
INSTALLMODULES += " \
"

KERNEL_MODULE_AUTOLOAD = "${INSTALLMODULES}"
