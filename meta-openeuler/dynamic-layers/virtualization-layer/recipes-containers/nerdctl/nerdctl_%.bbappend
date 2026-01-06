PV = "v2.0.0-beta.v1"
SRCREV_nerdcli = "265d6b9cf526ce7d9ed8d34a0e3c3066901cc463"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "\
    git://github.com/containerd/nerdctl.git;name=nerdcli;branch=main;protocol=https \
    file://0001-Makefile-allow-external-specification-of-build-setti.patch \
 "

inherit go
inherit goarch
inherit go-mod-vendor

PIEFLAG = "${@bb.utils.contains('GOBUILDFLAGS', '-buildmode=pie', '-buildmode=pie', '', d)}"

S = "${WORKDIR}/git"
GO_IMPORT = "import"
NERDCTL_SRC = "${S}/src/import"
NERDCTL_GOPROXY = "https://goproxy.cn,https://goproxy.io,https://mirrors.aliyun.com/goproxy/,direct"

GO_MOD_VENDOR_SRC_DIR = "${NERDCTL_SRC}"
GO_MOD_VENDOR_GOPROXY = "${NERDCTL_GOPROXY}"

do_compile() {
    cd ${NERDCTL_SRC}
    export GOPATH="$GOPATH:${NERDCTL_SRC}/.gopath"

    export GOARCH=${TARGET_GOARCH}
    export CGO_ENABLED="1"
    export CGO_CFLAGS="${CFLAGS} --sysroot=${STAGING_DIR_TARGET}"
    export CGO_LDFLAGS="${LDFLAGS} --sysroot=${STAGING_DIR_TARGET}"
    export GOFLAGS="-mod=vendor -trimpath ${PIEFLAG}"

    chmod_modcache

    oe_runmake GO=${GO} BUILDTAGS="${BUILDTAGS}" binaries
}
