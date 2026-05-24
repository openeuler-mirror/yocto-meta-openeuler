# main bbfile: yocto-poky/meta/recipes-kernel/dtc/dtc_1.6.0.bb

PV = "1.7.2"

# remove poky patches and apply the source packages from openEuler
SRC_URI = " \
                file://${BP}.tar.xz \
                file://backport-pylibfdt-libfdt.i-fix-backwards-compatibility-of-return-values.patch \
        "

# yocto-poky specifies 'S = "${WORKDIR}/git', but since we are using the openeuler package,
# we need to re-specify it
S = "${WORKDIR}/${BP}"
