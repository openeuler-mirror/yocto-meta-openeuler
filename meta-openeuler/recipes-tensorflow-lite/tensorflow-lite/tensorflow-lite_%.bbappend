# main bb file: yocto-meta-openeuler/meta-openeuler/recipes-tensorflow-lite/tensorflow-lite/tensorflow-lite_2.10.0.bb

PV = "2.10.0"

OPENEULER_REPO_NAME = "tensorflow"

DEPENDS:remove:libc-musl = "libgfortran"

SRC_URI:remove = " \
    file://fix-to-cmake-2.9.1.patch \
    file://tensorflow2-lite.pc.in \
"

SRC_URI = " \
    file://tensorflow-${PV}.tar.gz \
    file://external.tar.bz2.partaa \
    file://external.tar.bz2.partab \
    file://external.tar.bz2.partac \
    file://modify-deps-on-libclang-gcsfs-gast.patch \
    file://change-tools-cmake.patch \
"


S = "${WORKDIR}/tensorflow-${PV}"

EXTRA_OECMAKE:append = " -DTFLITE_ENABLE_XNNPACK=OFF "

DEPENDS += " \
    abseil-cpp  \
"

do_configure:prepend() {
	cat ${WORKDIR}/external.tar.* | tar -xvjf - -C ${WORKDIR}/
        mv ${WORKDIR}/external/eigen_archive ${WORKDIR}/build/eigen
        mv ${WORKDIR}/external/farmhash_archive ${WORKDIR}/build/farmhash
        mv ${WORKDIR}/external/gemmlowp ${WORKDIR}/build/gemmlowp
        mv ${WORKDIR}/external/cpuinfo ${WORKDIR}/build/cpuinfo
        mv ${WORKDIR}/external/ruy ${WORKDIR}/build/ruy
        mv ${WORKDIR}/external/flatbuffers ${WORKDIR}/build/flatbuffers
}

do_install() {
    # install libraries
    install -d ${D}${libdir}
    for lib in ${WORKDIR}/build/*.a
    do
        cp  $lib ${D}${libdir}
    done
    cp -r ${WORKDIR}/build/_deps ${D}${libdir}

    install -d ${D}${libdir}/pkgconfig

    # install header files
    install -d ${D}${includedir}/tensorflow/lite
    cd ${S}/tensorflow/lite
    cp --parents \
        $(find . -name "*.h*") \
        ${D}${includedir}/tensorflow/lite
    cp --parents \
        $(find . -name "*.fbs") \
        ${D}${includedir}/tensorflow/lite

    # install version.h from core
    install -d ${D}${includedir}/tensorflow/core/public
    cp ${S}/tensorflow/core/public/version.h ${D}${includedir}/tensorflow/core/public

}

FILES:${PN}-staticdev += "${libdir}/*"
FILES:${PN}-dev += "${libdir}/*"
