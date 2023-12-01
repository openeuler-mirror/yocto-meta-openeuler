inherit cargo
SUMMARY = "lib-shim-v2 is shim v2 ttrpc client which is called by iSulad."
DESCRIPTION = "Based on Rust programming language, as a shim v2 ttrpc client, it is called by iSulad."
HOMEPAGE = "https://gitee.com/openeuler/lib-shim-v2"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://README.md;md5=d604563bbee4408a10fdefa08f9368a2"

OPENEULER_REPO_NAME = "lib-shim-v2"

PV = "0.0.1"

# support for loongarch64 pathes not apply current:
# 0001-add-loongarch64-support-for-nix.patch
# 0001-add-loongarch64-support-for-prost-build.patch
SRC_URI = "file://v${PV}.tar.gz \
"

# add riscv64 BuildRequires: protobuf-compiler
DEPENDS_riscv64 += "protobuf-native"

S = "${WORKDIR}/lib-shim-v2-v${PV}"

do_install_append () {
    install -d ${D}/${libdir}
    install -d ${D}/${includedir}
    install -m 0755 ${WORKDIR}/target/*/release/*so ${D}/${libdir}
    install -m 0644 ${S}/shim_v2.h ${D}/${includedir}
}

FILES_${PN} = " \
    ${libdir} \
"

FILES_${PN}-dev = " \
    ${libdir}/libshim_v2.so.${PV} \
    ${includedir} \
"


# use local deps, provided by source tarball
create_cargo_config_append() {
    cat <<- EOF >> ${CARGO_HOME}/config
[source.crates-io]
replace-with = "local-registry"

[source.local-registry]
directory = "lib-shim-v2-v${PV}/vendor"

EOF
}

