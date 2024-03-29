# reference: yocto-meta-openembedded/meta-oe/recipes-devtools/suitesparse/suitesparse_5.10.1.bb
inherit ros_distro_humble

PV = "5.10.1"

# the local directory name holding suitesparse-${PV}.tar.gz
S = "${WORKDIR}/SuiteSparse-${PV}"

# patches cannot be applied
SRC_URI:remove = " \
            file://0001-Preserve-CXXFLAGS-from-environment-in-Mongoose.patch \
            file://0002-Preserve-links-when-installing-libmetis.patch \
            file://0003-Add-version-information-to-libmetis.patch \
           "

# local openeuler source
SRC_URI:prepend = "file://SuiteSparse-${PV}.tar.gz \
"

FILES:${PN} += "${libdir}/libmetis.so \
${libdir}/libamd.so \
${libdir}/libamd.so.2 \
${libdir}/libbtf.so \
${libdir}/libbtf.so.1 \
${libdir}/libcamd.so \
${libdir}/libcamd.so.2 \
${libdir}/libccolamd.so \
${libdir}/libccolamd.so.2 \
${libdir}/libcholmod.so \
${libdir}/libcholmod.so.3 \
${libdir}/libcolamd.so \
${libdir}/libcolamd.so.2 \
${libdir}/libcxsparse.so \
${libdir}/libcxsparse.so.3 \
${libdir}/libgraphblas.so \
${libdir}/libgraphblas.so.5 \
${libdir}/libklu.so \
${libdir}/libklu.so.1 \
${libdir}/libldl.so \
${libdir}/libldl.so.2 \
${libdir}/libmongoose.so \
${libdir}/libmongoose.so.2 \
${libdir}/librbio.so \
${libdir}/librbio.so.2 \
${libdir}/libsliplu.so \
${libdir}/libsliplu.so.1 \
${libdir}/libspqr.so \
${libdir}/libspqr.so.2 \
${libdir}/libsuitesparseconfig.so \
${libdir}/libsuitesparseconfig.so.5 \
${libdir}/libumfpack.so \
${libdir}/libumfpack.so.5 \
"

FILES:${PN}-dev = " \
${includedir} \
"

INSANE_SKIP:${PN} += "dev-so"
