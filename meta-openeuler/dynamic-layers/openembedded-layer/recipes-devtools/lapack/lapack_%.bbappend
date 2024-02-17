# main bbfile: yocto-meta-openembedded/meta-oe/recipes-devtools/lapack/lapack_3.9.0.bb

LIC_FILES_CHKSUM = "file://LICENSE;md5=39902829ba0c2cbac1b0debfb75a416b"

# version in openEuler
PV = "3.10.0"
S = "${WORKDIR}/lapack-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
"
# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://v${PV}.tar.gz \
    file://0001-fix-lapack-devel-build-error.patch \
    file://0002-Fix-out-of-bounds-read-in-slarrv.patch \
"

SRC_URI[md5sum] = "d70fc27a8bdebe00481c97c728184f09"
SRC_URI[sha256sum] = "328c1bea493a32cac5257d84157dc686cc3ab0b004e2bea22044e0a59f6f8a19"
