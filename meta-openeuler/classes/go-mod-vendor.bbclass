# Go Module Vendor Support Class
#
# This class provides common functionality for Go recipes that use go mod vendor
# to manage dependencies. It handles:
# - Setting up vendor directories with proper permissions
# - Validating existing vendor directories
# - Running go mod vendor when needed
#
# Usage:
#   inherit go-mod-vendor
#
# Required variables to set:
#   GO_MOD_VENDOR_SRC_DIR: The source directory containing go.mod
#   GO_MOD_VENDOR_GOPROXY: The GOPROXY URL to use
#
# Optional variables:
#   GO_MOD_VENDOR_DIR: The vendor directory (default: ${GO_MOD_VENDOR_SRC_DIR}/vendor)
#   GO_MOD_VENDOR_GOARCH: GOARCH setting (default: ${TARGET_GOARCH})
#   GO_MOD_VENDOR_WORKDIR: Working directory for go commands (default: ${GO_MOD_VENDOR_SRC_DIR})

GO_MOD_VENDOR_DIR ?= "${GO_MOD_VENDOR_SRC_DIR}/vendor"
GO_MOD_VENDOR_GOARCH ?= "${TARGET_GOARCH}"
GO_MOD_VENDOR_WORKDIR ?= "${GO_MOD_VENDOR_SRC_DIR}"
GOMODCACHE = "${GO_MOD_VENDOR_SRC_DIR}/pkg/mod"

chmod_modcache() {
    if [ -d "${GOMODCACHE}" ]; then
        chmod -R u+rwX,go+rwX "${GOMODCACHE}"
    fi

    if [ -d "${B}/pkg" ]; then
        chmod -R u+rwX,go+rwX "${B}/pkg"
        bbnote "change permission for current pkg directory"
    fi

    if [ -d "${GO_MOD_VENDOR_DIR}" ]; then
        chmod -R u+rwX,go+rwX "${GO_MOD_VENDOR_DIR}"
        bbnote "change permission for vendor directory"
    fi
}

vendor_ok() {
    if [ ! -d "${GO_MOD_VENDOR_DIR}" ]; then
        bbnote "** ${PN} vendor directory missing, refreshing dependencies"
        return 1
    fi
    (
        cd ${GO_MOD_VENDOR_WORKDIR}
        GO111MODULE=on GOFLAGS="-mod=vendor" ${GO} list ./... >/dev/null 2>&1
    )
    rc=$?
    if [ ${rc} -ne 0 ]; then
        bbwarn "** vendor directory validation failed"
        return ${rc}
    fi

    (
        cd ${GO_MOD_VENDOR_WORKDIR}
        GO111MODULE=on GOFLAGS="-mod=vendor" ${GO} mod verify >/dev/null 2>&1
    )
    rc=$?
    if [ ${rc} -ne 0 ]; then
        bbwarn "vendor directory verification failed"
    fi
    return ${rc}
}

# Dynamically add go toolchain dependencies based on DEPENDS_GOLANG
# This handles both native builds (go-native) and cross-compilation
# (virtual/${TUNE_PKGARCH}-go virtual/${TARGET_PREFIX}go-runtime)
python __anonymous() {
    depends = d.getVar('DEPENDS_GOLANG') or ''
    for dep in depends.split():
        d.appendVarFlag('do_setup_deps', 'depends', ' %s:do_populate_sysroot' % dep)
}

do_setup_deps[prefuncs] = "chmod_modcache"
do_setup_deps[postfuncs] = "chmod_modcache"
do_setup_deps[network] = "1"

do_setup_deps() {
    export GO111MODULE=on
    export GOARCH="${GO_MOD_VENDOR_GOARCH}"
    export GOPROXY="${GO_MOD_VENDOR_GOPROXY}"

    cd ${GO_MOD_VENDOR_WORKDIR}

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
