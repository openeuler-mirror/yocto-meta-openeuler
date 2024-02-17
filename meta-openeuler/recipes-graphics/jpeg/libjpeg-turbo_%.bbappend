# main bbfile: yocto-poky/meta/recipes-graphics/jpeg/libjpeg-turbo_2.1.5.1.bb


# version in openEuler
PV = "3.0.0"

# new lic checksumb
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=2a8e0d8226a102f07ab63ed7fd6ce155"

SRC_URI:remove = "file://0001-libjpeg-turbo-fix-package_qa-error.patch"

SRC_URI:prepend = "file://libjpeg-turbo-${PV}.tar.gz \
"

# QA Issue: libturbojpeg: /usr/lib64/libturbojpeg.so.0.3.0 
# contains probably-redundant RPATH /usr/lib64 [useless-rpaths]
ERROR_QA:remove = "useless-rpaths"
