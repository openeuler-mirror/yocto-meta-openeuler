SUMMARY = "A lightweight C++/C based container runtime daemon"
DESCRIPTION = "iSulad is a lightweight container runtime daemon which is designed for IOT and \
                Cloud infrastructure.iSulad has the characteristics of light, fast and not limited \
                by hardware specifications and architecture, and can be applied more widely"
HOMEPAGE = "https://gitee.com/openeuler/iSulad"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://LICENSES/LICENSE;md5=1acb172ffd3d252285dd1b8b8459941e"

OPENEULER_LOCAL_NAME = "iSulad"

inherit features_check
REQUIRED_DISTRO_FEATURES = "isulad"

# file and patches from openEuler
SRC_URI = " \
        file://v${PV}.tar.gz \
        file://0001-update-test-cutils-utils_error-utils_error_ut.cc.patch \
        file://0002-automatically-identify-ramdisk-scenarios-in-ramdisk.patch \
        file://0003-modify-cmake-file-for-ninja.patch \
        file://0004-modify-the-dns-field-to-be-optional.patch \
        file://0005-fix-the-incorrect-iSulad-configuration-file-location.patch \
        file://0006-fix-the-problem-where-m_update_rep-was-initialized-a.patch \
        file://0007-add-some-ut-for-isulad-default-runtime-change-tobe-r.patch \
        file://0008-docs-improve-README-with-development-setup-and-troub.patch \
        file://0009-fix-the-problem-of-missing-termios-header-file.patch \
        file://0010-fix-pointer-arithmetic-error-in-path-length-validation.patch \
"

# openEuler Embedded's modification
# 0001-configuration-use-lcr.patch: use lcr instead of runc
# config_cgroup: configure cgroups when the system does not use systemd
# isulad.service: systemd service file for isulad
SRC_URI:append = " \
        file://0001-configuration-use-lcr.patch \
        file://config_cgroup \
        file://isulad.service \
"

S = "${WORKDIR}/iSulad-v${PV}"

inherit cmake pkgconfig
OECMAKE_GENERATOR = "Unix Makefiles"

USE_PREBUILD_SHIM_V2 = "1"


DEPENDS += " \
        yajl zlib libarchive http-parser curl lcr libevent libevhtp openssl libwebsockets libdevmapper \
        protobuf libseccomp libcap libselinux ncurses \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)} \
        grpc grpc-native protobuf-native \
        ${@bb.utils.contains('USE_PREBUILD_SHIM_V2', '1', 'lib-shim-v2-bin', 'lib-shim-v2', d)} \
"

RDEPENDS:${PN} += " \
        yajl zlib libarchive http-parser curl lcr libevent libevhtp openssl libwebsockets libdevmapper \
        protobuf libseccomp libcap libselinux ncurses \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)} \
        grpc \
        glibc-binary-localedata-en-us \
        ${@bb.utils.contains('USE_PREBUILD_SHIM_V2', '1', 'lib-shim-v2-bin', 'lib-shim-v2', d)} \
"

EXTRA_OECMAKE = " \
        -DENABLE_GRPC=ON -DENABLE_GRPC_REMOTE_CONNECT=OFF \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '-DENABLE_SYSTEMD_NOTIFY=ON', '-DENABLE_SYSTEMD_NOTIFY=OFF', d)} \
        -DDEBUG=ON \
        -DCMAKE_SKIP_RPATH=TRUE \
        -DENABLE_SHIM_V2=OFF \
        -DENABLE_UT=OFF \
        -DENABLE_CRI_API_V1=ON \
        -DENABLE_CDI=ON \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMD_PROTOC=${STAGING_BINDIR_NATIVE}/protoc \
        -DCMD_GRPC_CPP_PLUGIN=${STAGING_BINDIR_NATIVE}/grpc_cpp_plugin \
"

# lib-shim-v2 depends on rust which is not well supported for arm32 and riscv64
# there are issues with building grpc on arm32 and riscv platforms.
DEPENDS:remove:arm = " lib-shim-v2 lib-shim-v2-bin grpc grpc-native "
RDEPENDS:${PN}:remove:arm = " lib-shim-v2 lib-shim-v2-bin grpc "
EXTRA_OECMAKE:remove:arm = " -DENABLE_SHIM_V2=ON -DENABLE_GRPC=ON "
EXTRA_OECMAKE:append:arm = " -DENABLE_SHIM_V2=OFF -DENABLE_GRPC=OFF "

DEPENDS:remove:riscv64 = " lib-shim-v2 lib-shim-v2-bin grpc grpc-native "
RDEPENDS:${PN}:remove:riscv64 = " lib-shim-v2 lib-shim-v2-bin grpc "
EXTRA_OECMAKE:remove:riscv64 = " -DENABLE_SHIM_V2=ON -DENABLE_GRPC=ON "
EXTRA_OECMAKE:append:riscv64 = " -DENABLE_SHIM_V2=OFF -DENABLE_GRPC=OFF "

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

FILES:${PN} += "${libdir}/* "
#remove so from ${PN}-dev
FILES_SOLIBSDEV = ""

do_configure:prepend() {
    grep -q CMAKE_SYSROOT ${WORKDIR}/toolchain.cmake || cat >> ${WORKDIR}/toolchain.cmake <<EOF
    set( CMAKE_SYSROOT ${STAGING_DIR_HOST} )
EOF
}

do_configure:append() {
    sed -i "10 a\# undef linux" ${WORKDIR}/build/grpc/src/api/services/cri/v1alpha/api.pb.h
    sed -i "10 a\# undef linux" ${WORKDIR}/build/grpc/src/api/services/cri/v1/api_v1.pb.h
}

DEPENDS += "update-rc.d-native"

do_install:append () {
    [[ "${libdir}" != "/usr/lib" ]] || return 0
    if test -d ${D}/usr/lib ; then
            install -d ${D}/${libdir}
            mv ${D}/usr/lib/* ${D}/${libdir}
            rm -rf ${D}/usr/lib/
    fi

    has_systemd="${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'True', 'False', d)}"
	# if the system uses systemd, manage isulad with it
	# the indentation of the word "EOF" is important, do not change it
	if [ $has_systemd = "True" ]; then
		install -d ${D}${sysconfdir}/systemd/system
		# create isulad.service file so systemd can manage isulad based on it
		if [ ! -e ${D}${sysconfdir}/systemd/system/isulad.service ]; then
            install -m 0644 ${WORKDIR}/isulad.service ${D}${sysconfdir}/systemd/system
		fi
	fi

    # if the os does not contain systemd, install init script configuring cgroups
    # because isulad needs cgroups to control resources
    if [ $has_systemd = "False" ]; then
        install -d ${D}${sysconfdir}/init.d
        install -m 0755 ${WORKDIR}/config_cgroup ${D}${sysconfdir}/init.d
        # empower auto configuration of cgroups each time the system boots
        install -d ${D}${sysconfdir}/rcS.d
        update-rc.d -r ${D} config_cgroup start 99 5 .
    fi
}
