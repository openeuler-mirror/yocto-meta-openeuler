SUMMARY = "A new type of software package"
DESCRIPTION = "Install epkg"

PV = "0.3.0"

SRC_URI += " \
   file://${BPN}-${PV}.tar.gz \
   file://rootfs.tar.gz \
   "

do_compile[noexec] = "1"

LICENSE = "MulanPSL-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

opt_epkg = "${D}/opt/epkg"
cache_root = "${opt_epkg}/cache"
store_root = "${opt_epkg}/store"
common_root = "${opt_epkg}/users/public/envs/common"
pkg_cache = "${opt_epkg}/cache/packages"
channel_cache = "${opt_epkg}/cache/channel"
rc_path = "${D}/etc/profile.d/epkg.sh"

do_install:append() {
    install -d ${opt_epkg}
    install -d ${D}/etc/profile.d
    install -d ${common_root}/profile-1/usr
    install -d ${common_root}/profile-1/usr/lib
    install -d ${common_root}/profile-1/etc/epkg
    install -d ${common_root}/profile-1/usr/bin
    install -d ${common_root}/profile-1/usr/bin
    install -d ${cache_root}

    cd ${common_root}/profile-1
    ln -sT usr/bin     bin
    ln -sT usr/sbin    sbin
    ln -sT usr/lib     lib
    ln -sT usr/lib64   lib64
    cd ${common_root}/
    ln -sT profile-1 profile-current

    cp -a ${S} ${cache_root}/epkg-manager
    rm -rf ${cache_root}/epkg-manager/target

    cp -a ${S}/bin ${common_root}/profile-1/usr/
    cp -a ${S}/lib/epkg ${common_root}/profile-1/usr/lib/
    cp -a ${S}/build ${opt_epkg}

    install -m 0755 ${S}/channel/openEuler-24.03-LTS-channel.yaml ${common_root}/profile-1/etc/epkg/channel.yaml
    install -m 0755 ${WORKDIR}/rootfs/elf-loader-${TARGET_ARCH} ${common_root}/profile-1/usr/bin/elf-loader
    install -m 0755 ${WORKDIR}/rootfs/epkg-${TARGET_ARCH} ${common_root}/profile-1/usr/bin/epkg

    chown -R root:root ${opt_epkg}
    chmod -R 755 ${opt_epkg}
    chmod 4755 ${common_root}/profile-1/usr/bin/epkg

    cat >${rc_path} <<EOF
source /opt/epkg/users/public/envs/common/profile-current/usr/lib/epkg/epkg-rc.sh
EOF
}

FILES:${PN} += "/opt"
FILES:${PN} += "/etc/profile.d/epkg.sh"
INSANE_SKIP:${PN} += "already-stripped"
