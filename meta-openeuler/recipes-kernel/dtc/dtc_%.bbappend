# main bbfile: yocto-poky/meta/recipes-kernel/dtc/dtc_1.6.0.bb

PV = "1.6.1"

# Use the source packages from openEuler, remove patch conflict with openeuler
SRC_URI:remove = " \
        git://git.kernel.org/pub/scm/utils/dtc/dtc.git;branch=master \
        file://0001-fdtdump-Fix-gcc11-warning.patch \
        "

# openEuler-add-secure-compile-option-in-Makefile.patch can't apply
SRC_URI:append = " \
                file://${BP}.tar.xz \
        "

# yocto-poky specifies 'S = "${WORKDIR}/git', but since we are using the openeuler package,
# we need to re-specify it
S = "${WORKDIR}/${BP}"
