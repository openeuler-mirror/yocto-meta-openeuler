SUMMARY = "A lightweight cross-platform package manager"
DESCRIPTION = "epkg is a lightweight cross-platform package manager developed \
by the openEuler community. It creates isolated environments to install and run \
packages from common distributions (RPM, DEB, Alpine, Arch, Conda, ...) without \
root privileges. This recipe ships the upstream prebuilt static binary for the \
target architecture, following the same scheme as bin/install.sh in the epkg \
source tree."
HOMEPAGE = "https://atomgit.com/openeuler/epkg"

LICENSE = "MulanPSL-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

PV = "0.2.6"

# The prebuilt binaries are published as gitee release assets (the same source
# that upstream bin/install.sh downloads from). Only architectures listed in
# EPKG_RELEASE_SHA256 are supported; others are skipped at parse time, which is
# aligned with check_architecture() in bin/install.sh.
python () {
    epkg_release_sha256 = {
        "x86_64": "bb6b4db0d77a5934468f6ee0171f9ccee834ac9de564853916c2bf022ca82b23",
        "aarch64": "87f66d75276d470887ed6e6d1b27a942fe104f92ec8145cee5e79bc35a20c16e",
        "riscv64": "6a6486710f19b06166ae0329622b46d43da6789db01d7e406da282b60acf153e",
        "loongarch64": "e222376102777885b3c7eb7fdb6b6afd55089e7ddefe8bf1935c65c5f15949c4",
    }
    arch = d.getVar("TARGET_ARCH")
    if arch not in epkg_release_sha256:
        raise bb.parse.SkipRecipe("epkg does not provide a prebuilt binary for %s" % arch)
    d.setVar("EPKG_RELEASE_SHA256", epkg_release_sha256[arch])
}

SRC_URI = "https://gitee.com/wu_fengguang/epkg/releases/download/v${PV}/epkg-linux-${TARGET_ARCH};downloadfilename=epkg-linux-${TARGET_ARCH}-${PV};sha256sum=${EPKG_RELEASE_SHA256}"

UPSTREAM_CHECK_URI = "https://gitee.com/wu_fengguang/epkg/releases"

do_compile[noexec] = "1"

# Install to /usr/local/bin instead of /usr/bin: the upstream layout created
# by 'epkg self install' keeps epkg under /opt/epkg/.../self/usr/bin and links
# /usr/local/bin/epkg to it. When epkg is launched from /usr/bin, its sandbox
# bind-mounts the epkg binary directory (/usr/bin) into the environment, hiding
# the environment's own /usr/bin binaries. /usr/local/bin is harmless because
# environments do not use that path.
do_install() {
    # The binary is fully self-contained (statically linked). Environment and
    # shell rc initialization is done at runtime via 'epkg self install'.
    install -d ${D}${prefix}/local/bin
    install -m 0755 ${WORKDIR}/epkg-linux-${TARGET_ARCH}-${PV} ${D}${prefix}/local/bin/epkg
}

FILES:${PN} += "${prefix}/local/bin/epkg"

INSANE_SKIP:${PN} += "already-stripped"
