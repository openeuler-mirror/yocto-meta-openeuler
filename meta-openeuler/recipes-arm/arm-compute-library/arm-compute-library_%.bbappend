# main bb file: yocto-meta-openeuler/meta-openeuler/recipes-arm/arm-compute-library/arm-compute-library_22.11.bb
PV = "22.11"

OPENEULER_REPO_NAME = "ComputeLibrary"

LIC_FILES_CHKSUM = "file://LICENSE;md5=f3c5879801d3cffc4ac2399f2b8e8ec5"

SRC_URI = " \
    file://ComputeLibrary-${PV}.tar.gz \
    file://0001-update-scon-configuration-for-yocto-build.patch \
"
SRC_URI[arm-compute-library.sha256sum] = "2f70f54d84390625222503ea38650c00c49d4b70bc86a6b9aeeebee9d243865f"

S = "${WORKDIR}/ComputeLibrary-${PV}"

EXTRA_OESCONS = "arch=arm64-v8a extra_cxx_flags="-fPIC -Wno-unused-but-set-variable -Wno-ignored-qualifiers -Wno-noexcept -Wno-strict-overflow -Wno-array-bounds" benchmark_tests=1 validation_tests=0 set_soname=1"
EXTRA_OESCONS += "neon=1 opencl=0 embed_kernels=1"
EXTRA_OESCONS:remove = "MAXLINELENGTH=2097152"

do_configure() {
        if [ -n "${CONFIGURESTAMPFILE}" -a "${S}" = "${B}" ]; then
                if [ -e "${CONFIGURESTAMPFILE}" -a "`cat ${CONFIGURESTAMPFILE}`" != "${BB_TASKHASH}" -a "${CLEANBROKEN}" != "1" ]; then
                        ${STAGING_BINDIR_NATIVE}/scons --directory=${S} --clean ${EXTRA_OESCONS}
                fi

                mkdir -p `dirname ${CONFIGURESTAMPFILE}`
                echo ${BB_TASKHASH} > ${CONFIGURESTAMPFILE}
        fi
}

scons_do_compile() {
        ${STAGING_BINDIR_NATIVE}/scons ${PARALLEL_MAKE}  ${EXTRA_OESCONS} || \
        die "scons build execution failed."
}

do_install() {
    CP_ARGS="-Prf --preserve=mode,timestamps --no-preserve=ownership"

    install -d ${D}${libdir}
    for lib in ${S}/build/lib*.*
    do
        cp $CP_ARGS $lib ${D}${libdir}
    done

    # Install 'example' and benchmark executables
    install -d ${D}${bindir}
    find ${S}/build/examples/ -maxdepth 1 -type f -executable -exec cp $CP_ARGS {} ${D}${bindir} \;
    cp $CP_ARGS ${S}/build/tests/arm_compute_benchmark ${D}${bindir}

    # Install built source package as expected by ARMNN
    install -d ${D}${datadir}/${BPN}
    cp $CP_ARGS ${S}/arm_compute ${D}${datadir}/${BPN}/.
    cp $CP_ARGS ${S}/include ${D}${datadir}/${BPN}/.
    cp $CP_ARGS ${S}/support ${D}${datadir}/${BPN}/.
}

