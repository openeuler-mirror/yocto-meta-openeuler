# main bbfile: yocto-poky/meta/recipes-extended/stress-ng/stress-ng_0.13.12.bb

OPENEULER_SRC_URI_REMOVE = "git"

PV = "0.13.11"

# powerpc64 is not supported now 
# and this patch is located in the dir of 
# yocto-poky/meta/recipes-extended/stress-ng/stress-ng-0.13.12
# version number is different.
# if this patch is required, move this patch into openeuler 
SRC_URI:remove = " \
    file://0001-stress-cpu-disable-float128-math-on-powerpc64-to-avo.patch \
    "

SRC_URI:prepend = " \
    file://V${PV}.tar.gz \
"

S = "${WORKDIR}/${BP}"
