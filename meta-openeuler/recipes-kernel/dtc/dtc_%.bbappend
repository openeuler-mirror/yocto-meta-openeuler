# main bbfile: yocto-poky/meta/recipes-kernel/dtc/dtc_1.6.0.bb

PV = "1.7.0"

# remove poky patches and apply the source packages from openEuler
SRC_URI = " \
                file://${BP}.tar.xz \
                file://openEuler-add-secure-compile-option-in-Makefile.patch \
                file://remove-ldflags-in-cflags.patch \
        "

# yocto-poky specifies 'S = "${WORKDIR}/git', but since we are using the openeuler package,
# we need to re-specify it
S = "${WORKDIR}/${BP}"
