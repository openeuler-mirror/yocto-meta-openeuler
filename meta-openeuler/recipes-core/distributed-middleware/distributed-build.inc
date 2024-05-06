SUMMARY = "openEuler embedded softbus build tools"
DESCRIPTION = "Compile and build tools that based on GN and ninja for distributed middleware components."
PR = "r1"
LICENSE = "CLOSED"

inherit python3native
DEPENDS = "ninja-native libboundscheck python3-jinja2-native"

openHarmony_release_version = "OpenHarmony-v3.2-Release"
pkg-build = "build-${openHarmony_release_version}"
pkg-build-lite = "build_lite-${openHarmony_release_version}"

buildtools_dir = "${S}/prebuilts/build-tools/linux-x86/bin"

OPENEULER_MULTI_REPOS = "yocto-embedded-tools distributed-build distributed-build_lite"

SRC_URI = " \
        file://yocto-embedded-tools/dsoftbus/build_tools/gn-linux-x86-1717.tar.gz \
        file://distributed-build/${pkg-build}.tar.gz \
        file://distributed-build/0001-feat-Adapt-to-Openeuler-python-export-lld.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0002-feat-Adapt-to-Openeuler-for-compilation.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0003-feat-Adapt-to-Openeuler-add-clang.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0004-feat-Adapt-to-Openeuler-add-include-file.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0005-feat-use-pyyaml-on-openeuler.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0006-feat-add-base-config.json-for-openeuler.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0007-feat-add-gn-files-to-use-packages-on-openeuler.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0008-feat-Adapt-to-openeuler.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0009-feat-add-common-subsystem-and-delete-useless-config.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0012-fix-rpm-build-fail-caused-by-wrong-useless-code.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0013-feature-use-llvm-tools-version-15-for-build.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0014-feat-delete-the-default-sqlite-deps.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0015-feat-and-hilog-gn-files.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0016-fix-use-llvm15-path-on-x86_64.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0017-feat-add-script-to-create-soft-link.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0020-feat-add-openssl-gn-file-and-soft-link.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0021-feat-change-config-json.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0022-add-build-gn-file-of-icu-jsoncpp-zlib.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0023-feat-for-embedded-comment-out-sysroot_hash.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0024-feat-for-embedded-add-linux_arm64-toolchain.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build/0025-feat-for-embedded-fix-sysroot-path.patch;patchdir=${WORKDIR}/${pkg-build} \
        file://distributed-build_lite/${pkg-build-lite}.tar.gz \
        file://distributed-build_lite/0001-feat-Adapt-to-Openeuler-python.patch;patchdir=${WORKDIR}/${pkg-build-lite} \
        file://distributed-build_lite/0002-feat-Adapt-to-Openeuler-productdefine.patch;patchdir=${WORKDIR}/${pkg-build-lite} \
        file://distributed-build_lite/0003-feat-Adapt-to-Openeule-remove-useless-code.patch;patchdir=${WORKDIR}/${pkg-build-lite} \
        file://distributed-build_lite/0004-feat-for-embedded-check-clang-path.patch;patchdir=${WORKDIR}/${pkg-build-lite} \
        "

SRC_URI:append = " \
        file://0001-feat-for-embedded-comment-out-unrecognized-options.patch;patchdir=${WORKDIR}/${pkg-build} \
"

python do_fetch:prepend() {
    bb.build.exec_func("do_openeuler_fetch_multi", d)
}

do_patch:append() {
    bb.build.exec_func('do_prepare_build_directory', d)
    bb.build.exec_func('do_prepare_vendor_directory', d)
    bb.build.exec_func('do_prepare_third_party_directory', d)
    bb.build.exec_func('do_prepare_toolchain_directory', d)
}

do_prepare_toolchain_directory() {
    mkdir -p ${buildtools_dir}
    cp -rfp ${WORKDIR}/gn ${buildtools_dir}/

    # link toolchain
    if [ ! -e ${S}/toolchain ]; then
        ln -s ${EXTERNAL_TOOLCHAIN} ${S}/toolchain
    fi
}

do_prepare_build_directory() {
    find ${WORKDIR}/${pkg-build}/openeuler/compiler_gn -type l | xargs -t -i rm {}

    mkdir -p ${S}/build
    cp -rfp ${WORKDIR}/${pkg-build}/* ${S}/build

    mkdir -p ${S}/build/lite
    cp -rfp ${WORKDIR}/${pkg-build-lite}/* ${S}/build/lite

    rm -f ${S}/build.sh
    sed -i "s@PYTHON3_DIR=/usr@PYTHON3_DIR=${OPENEULER_NATIVESDK_SYSROOT}/usr@" ${S}/build/build_scripts/build.sh
    ln -s ${S}/build/build_scripts/build.sh ${S}/build.sh

    rm -f ${S}/.gn
    sed -i "s@^script_executable = \"/usr/bin/env\"@script_executable = \"${OPENEULER_NATIVESDK_SYSROOT}/usr/bin/python\"@" ${S}/build/core/gn/dotfile.gn
    ln -s ${S}/build/core/gn/dotfile.gn ${S}/.gn

    rm -f ${S}/build.py
    ln -s ${S}/build/lite/build.py ${S}/build.py
}

do_prepare_vendor_directory() {
    mkdir -p ${S}/vendor
    cp -rfp ${WORKDIR}/${pkg-build}/openeuler/vendor/* ${S}/vendor
}

do_prepare_third_party_directory() {
    mkdir -p ${S}/third_party
    cp -rfp ${WORKDIR}/${pkg-build}/openeuler/compiler_gn/third_party/* ${S}/third_party
}