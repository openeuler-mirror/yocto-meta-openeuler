# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/re2/re2_2020.11.01.bb

# version in openEuler
PV = "2024.02.01"
S = "${WORKDIR}/re2-2024-02-01"

SRCREV = "2d866a3d0753f4f4fce93cccc6c59c4b052d7db4"

# sync with high version of oe config:
# ignore .so in /usr/lib64
INSANE_SKIP:${PN} += "dev-so"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://2024-02-01.tar.gz \
    file://add-some-testcases-for-abnormal-branches.patch \
"

DEPENDS = "abseil-cpp ${@bb.utils.contains('PTEST_ENABLED', '1', 'gtest googlebenchmark', '', d)}"

inherit ptest

RDEPENDS:${PN}-ptest += "cmake sed"
RDEPENDS:${PN} += "abseil-cpp-dev"

INSANE_SKIP:${PN} += "dev-deps"

EXTRA_OECMAKE:remove = "\
            -DRE2_BUILD_TESTING=OFF \
"

EXTRA_OECMAKE += "\
     ${@bb.utils.contains('PTEST_ENABLED', '1', '-DRE2_BUILD_TESTING=ON', '-DRE2_BUILD_TESTING=OFF', d)} \
"

do_install_ptest () {
    cp -r ${B}/*_test ${D}${PTEST_PATH}
    cp -r ${B}/CTestTestfile.cmake ${D}${PTEST_PATH}
    sed -i -e 's#${B}#${PTEST_PATH}#g' `find ${D}${PTEST_PATH} -name CTestTestfile.cmake`
    sed -i -e 's#${S}#${PTEST_PATH}#g' `find ${D}${PTEST_PATH} -name CTestTestfile.cmake`
    # ERROR: re2-2024.03.01-r0 do_package_qa: QA Issue: /usr/lib64/re2/ptest/string_generator_test contained in package re2-ptest requires libtesting.so()(64bit), but no providers found in RDEPENDS:re2-ptest? [file-rdeps]
    cp -r ${B}/libtesting.so ${D}${PTEST_PATH}
}

# ignore .so in /usr/lib64
INSANE_SKIP:${PN} += "dev-so"
