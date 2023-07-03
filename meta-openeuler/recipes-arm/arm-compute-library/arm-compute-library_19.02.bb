SUMMARY = "The ARM Computer Vision and Machine Learning library"
DESCRIPTION = "The ARM Computer Vision and Machine Learning library is a set of functions optimised for both ARM CPUs and GPUs."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=762a7ba8d2ddc3b38d88742fbaf0b62d"

inherit scons

SRC_URI = " \
    git://github.com/ARM-software/ComputeLibrary.git;tag=v${PV};name=arm-compute-library \
    file://0001-update-scon-configuration-for-yocto-build.patch \
"

S = "${WORKDIR}/git"

LIBS += "-larmpl_lp64_mp"

do_install() {
    CP_ARGS="-Prf --preserve=mode,timestamps --no-preserve=ownership"

    install -d ${D}${libdir}
    for lib in ${S}/build/*.so*
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

INSANE_SKIP:${PN} = "ldflags"
INSANE_SKIP:${PN}-dev = "dev-elf ldflags"

FILES:${PN}-source = "${datadir}/${BPN}"
INSANE_SKIP:${PN}-source = "ldflags libdir staticdev"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

