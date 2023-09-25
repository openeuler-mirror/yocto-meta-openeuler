#main bb file: yocto-meta-openeuler/meta-openeuler/recipes-arm/arm-compute-library/armnn_22.11.bb
PV = "22.11"

SRCREV = "d95bb5364783c89ea9594550233055590db31094"

CXXFLAGS += "-fopenmp -O3 -DNDEBUG"
LIBS += "-larmpl_lp64_mp"

EXTRA_OECMAKE=" \
    -DCMAKE_CXX_FLAGS=-w \ 
    -DBUILD_SHARED_LIBS=ON  \
    -DARMCOMPUTE_ROOT=${STAGING_DIR_HOST}${datadir}/arm-compute-library \
    -DARMCOMPUTE_BUILD_DIR=${STAGING_DIR_HOST}${libdir} \
    -DFLATBUFFERS_INCLUDE_PATH=${STAGING_DIR_HOST}${includedir} \
    -DFLATBUFFERS_LIBRARY=${STAGING_DIR_HOST}${libdir}/libflatbuffers.a \
    -DFlatbuffers_INCLUDE_DIR=${STAGING_DIR_HOST}${includedir} \
    -DFlatbuffers_LIB=${STAGING_DIR_HOST}${libdir}/libflatbuffers.a \
    -DTF_LITE_SCHEMA_INCLUDE_PATH=${STAGING_DIR_HOST}${includedir}/tensorflow/lite/schema \
    -DTENSORFLOW_ROOT=${STAGING_DIR_HOST}${includedir} \
    -DTFLITE_LIB_ROOT=${STAGING_DIR_HOST}${libdir} \
    -DARMCOMPUTENEON=1 -DARMCOMPUTECL=0 -DARMNNREF=1 \
    -DBUILD_TF_LITE_PARSER=1 \
    -DBUILD_ONNX_PARSER=0 \
    -DBUILD_ARMNN_TFLITE_DELEGATE=1 \
    -DFLATC_DIR=${STAGING_DIR_NATIVE}${bindir} \
    -DBUILD_TESTS=1 \
    -DGENERIC_LIB_VERSION=${PV} -DGENERIC_LIB_SOVERSION=${PV_MAJOR} \
"

cmake_do_configure() {
        if [ "${OECMAKE_BUILDPATH}" ]; then
                bbnote "cmake.bbclass no longer uses OECMAKE_BUILDPATH.  The default behaviour is now out-of-tree builds with B=WORKDIR/build."
        fi

        if [ "${S}" = "${B}" ]; then
                find ${B} -name CMakeFiles -or -name Makefile -or -name cmake_install.cmake -or -name CMakeCache.txt -delete
        fi

        # Just like autotools cmake can use a site file to cache result that need generated binaries to run
        if [ -e ${WORKDIR}/site-file.cmake ] ; then
                oecmake_sitefile="-C ${WORKDIR}/site-file.cmake"
        else
                oecmake_sitefile=
        fi

        cmake \
          $oecmake_sitefile \
          ${OECMAKE_SOURCEPATH} \
          -DCMAKE_INSTALL_PREFIX:PATH=${prefix} \
          -DCMAKE_INSTALL_BINDIR:PATH=${@os.path.relpath(d.getVar('bindir'), d.getVar('prefix') + '/')} \
          -DCMAKE_INSTALL_SBINDIR:PATH=${@os.path.relpath(d.getVar('sbindir'), d.getVar('prefix') + '/')} \
          -DCMAKE_INSTALL_LIBEXECDIR:PATH=${@os.path.relpath(d.getVar('libexecdir'), d.getVar('prefix') + '/')} \
          -DCMAKE_INSTALL_SYSCONFDIR:PATH=${sysconfdir} \
          -DCMAKE_INSTALL_SHAREDSTATEDIR:PATH=${@os.path.relpath(d.getVar('sharedstatedir'), d.  getVar('prefix') + '/')} \
          -DCMAKE_INSTALL_LOCALSTATEDIR:PATH=${localstatedir} \
          -DCMAKE_INSTALL_LIBDIR:PATH=${@os.path.relpath(d.getVar('libdir'), d.getVar('prefix') + '/')} \
          -DCMAKE_INSTALL_INCLUDEDIR:PATH=${@os.path.relpath(d.getVar('includedir'), d.getVar('prefix') + '/')} \
          -DCMAKE_INSTALL_DATAROOTDIR:PATH=${@os.path.relpath(d.getVar('datadir'), d.getVar('prefix') + '/')} \
          -DCMAKE_INSTALL_SO_NO_EXE=0 \
          -DCMAKE_NO_SYSTEM_FROM_IMPORTED=1 \
          ${EXTRA_OECMAKE} \
          -Wno-dev
}

SRC_URI:remove = " \
    git://github.com/ARM-software/armnn.git;name=armnn;branch=${BRANCH_ARMNN} \
    file://0001-stdlib-issue-work-around.patch \
    file://0002-enable-use-of-boost-shared-library.patch \
    file://0003-generate-versioned-library.patch \
    file://0004-enable-use-of-arm-compute-shared-library.patch \
    file://0005-add-support-more-examples.patch \
    file://TfLiteMobilenetQuantized_0_25-Armnn.cpp \
    file://TfLiteMobilenetQuantized_1_0-Armnn.cpp \
    file://grace_hopper.jpg \
"
SRC_URI += " \
   file://armnn-${PV}.tar.gz \
   file://armnn-use-static-libraries.patch \
   file://0001-modify-cmake-files.patch \
"
S = "${WORKDIR}/${BP}"

DEPENDS:remove = "\
    armnn-tensorflow-lite \
    stb \
"
DEPENDS += " \
    tensorflow-lite \
"

do_configure:remove() {
    install -m 0555 ${WORKDIR}/TfLiteMobilenetQuantized_0_25-Armnn.cpp ${S}/tests/TfLiteMobilenetQuantized-Armnn
    install -m 0555 ${WORKDIR}/TfLiteMobilenetQuantized_1_0-Armnn.cpp ${S}/tests/TfLiteMobilenetQuantized-Armnn
}

FILES:${PN} += "${libdir}/*"
