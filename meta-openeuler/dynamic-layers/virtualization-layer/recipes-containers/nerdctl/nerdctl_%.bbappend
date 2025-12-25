PV = "v2.0.0-beta.v1"
SRCREV_nerdcli = "265d6b9cf526ce7d9ed8d34a0e3c3066901cc463"

FILESEXTRAPATHS:prepend = "${THISDIR}:"

SRC_URI = "\
    git://github.com/containerd/nerdctl.git;name=nerdcli;branch=main;protocol=https \
    file://0001-Makefile-allow-external-specification-of-build-setti.patch \
    file://modules.txt \
 "

inherit go
inherit goarch

PIEFLAG = "${@bb.utils.contains('GOBUILDFLAGS', '-buildmode=pie', '-buildmode=pie', '', d)}"

S = "${WORKDIR}/git"
GO_IMPORT = "import"
NERDCTL_SRC = "${S}/src/import"
vendor_dir = "${NERDCTL_SRC}/vendor"
GOMODCACHE = "${NERDCTL_SRC}/pkg/mod"
NERDCTL_GOPROXY = "https://goproxy.cn,https://goproxy.io,https://mirrors.aliyun.com/goproxy/,direct"

# Ensure cached go vendor directory rw permissions are set correctly
chmod_modcache() {
    if [ -d "${GOMODCACHE}" ]; then
        chmod -R u+rwX,go+rwX "${GOMODCACHE}"
    fi

    if [ -d "${B}/pkg" ]; then
        chmod -R u+rwX,go+rwX "${B}/pkg"
        bbnote "change permission for current pkg directory"
    fi

    if [ -d "${vendor_dir}" ]; then
        chmod -R u+rwX,go+rwX "${vendor_dir}"
        bbnote "change permission for vendor directory"
    fi
}

vendor_ok() {
    if [ ! -d "${vendor_dir}" ]; then
        bbnote "** ${PN} vendor directory missing, refreshing dependencies"
        return 1
    fi
    (
        cd ${NERDCTL_SRC}
        GO111MODULE=on GOFLAGS="-mod=vendor" ${GO} list ./... >/dev/null 2>&1
    )
    rc=$?
    if [ ${rc} -ne 0 ]; then
        bbwarn "** vendor directory validation failed"
        return ${rc}
    fi

    (
        cd ${NERDCTL_SRC}
        GO111MODULE=on GOFLAGS="-mod=vendor" ${GO} mod verify >/dev/null 2>&1
    )
    rc=$?
    if [ ${rc} -ne 0 ]; then
        bbwarn "vendor directory verification failed"
    fi
    return ${rc}
}

# Setup dependencies using go mod vendor
do_setup_deps[prefuncs] = "chmod_modcache"
do_setup_deps[postfuncs] = "chmod_modcache"
do_setup_deps[network] = "1"
do_setup_deps() {
    export GO111MODULE=on
    export CGO_ENABLED="1"
    export GOARCH=${TARGET_GOARCH}
    export CGO_CFLAGS="${CFLAGS} --sysroot=${STAGING_DIR_TARGET}"
    export CGO_LDFLAGS="${LDFLAGS} --sysroot=${STAGING_DIR_TARGET}"
    export GOPROXY="${NERDCTL_GOPROXY}"

    cd ${NERDCTL_SRC}

    if vendor_ok; then
        bbnote "vendor directory healthy, skipping dependency setup"
        return
    fi

    bbwarn "** use GOPROXY=${GOPROXY}, if network issues occurred, try setting GOPROXY or modify your network configs"
    ${GO} mod vendor

    if ! ${GO} mod verify >/dev/null 2>&1; then
        bbfatal "go mod verify failed after vendoring"
    fi

    bbnote "go mod vendor finished"
}

addtask do_setup_deps after do_patch before do_compile

do_compile() {
    cd ${NERDCTL_SRC}
    export GOPATH="$GOPATH:${NERDCTL_SRC}/.gopath"

    # Pass the needed cflags/ldflags so that cgo
    # can find the needed headers files and libraries
    export GOARCH=${TARGET_GOARCH}
    export CGO_ENABLED="1"
    export CGO_CFLAGS="${CFLAGS} --sysroot=${STAGING_DIR_TARGET}"
    export CGO_LDFLAGS="${LDFLAGS} --sysroot=${STAGING_DIR_TARGET}"
    export GOFLAGS="-mod=vendor -trimpath ${PIEFLAG}"

    # Ensure vendor directory has correct permissions before compile
    chmod_modcache

    cp ${WORKDIR}/modules.txt vendor/
    oe_runmake GO=${GO} BUILDTAGS="${BUILDTAGS}" binaries
}
