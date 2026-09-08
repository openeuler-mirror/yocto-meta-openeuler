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
#
# Optional variables:
#   GO_MOD_VENDOR_DIR: The vendor directory (default: ${GO_MOD_VENDOR_SRC_DIR}/vendor)
#   GO_MOD_VENDOR_GOARCH: GOARCH setting (default: ${TARGET_GOARCH})
#   GO_MOD_VENDOR_WORKDIR: Working directory for go commands (default: ${GO_MOD_VENDOR_SRC_DIR})
#   GO_MOD_VENDOR_GOPROXY: GOPROXY setting for go mod vendor
#   GO_MOD_VENDOR_GOSUMDB: GOSUMDB setting for go mod vendor
#   GO_MOD_VENDOR_GODEBUG: GODEBUG setting for go mod vendor
#   GO_MOD_VENDOR_HTTP_PROXY/HTTPS_PROXY/NO_PROXY: optional proxy settings

GO_MOD_VENDOR_DIR ?= "${GO_MOD_VENDOR_SRC_DIR}/vendor"
GO_MOD_VENDOR_GOARCH ?= "${TARGET_GOARCH}"
GO_MOD_VENDOR_WORKDIR ?= "${GO_MOD_VENDOR_SRC_DIR}"
GO_MOD_VENDOR_GOPROXY ?= "https://goproxy.cn,https://mirrors.aliyun.com/goproxy/,direct"
GO_MOD_VENDOR_GOSUMDB ?= "off"
GO_MOD_VENDOR_GODEBUG ?= "http2client=0"
GO_MOD_VENDOR_HTTP_PROXY ?= "${@d.getVar('HTTP_PROXY') or d.getVar('http_proxy') or ''}"
GO_MOD_VENDOR_HTTPS_PROXY ?= "${@d.getVar('HTTPS_PROXY') or d.getVar('https_proxy') or ''}"
GO_MOD_VENDOR_NO_PROXY ?= "${@d.getVar('NO_PROXY') or d.getVar('no_proxy') or ''}"
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

    # go mod verify validates the module cache, not the vendor tree.
    return 0
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
    export GOSUMDB="${GO_MOD_VENDOR_GOSUMDB}"
    export GODEBUG="${GO_MOD_VENDOR_GODEBUG}"

    if [ -n "${GO_MOD_VENDOR_HTTP_PROXY}" ]; then
        export HTTP_PROXY="${GO_MOD_VENDOR_HTTP_PROXY}"
        export http_proxy="${GO_MOD_VENDOR_HTTP_PROXY}"
    fi
    if [ -n "${GO_MOD_VENDOR_HTTPS_PROXY}" ]; then
        export HTTPS_PROXY="${GO_MOD_VENDOR_HTTPS_PROXY}"
        export https_proxy="${GO_MOD_VENDOR_HTTPS_PROXY}"
    fi
    if [ -n "${GO_MOD_VENDOR_NO_PROXY}" ]; then
        export NO_PROXY="${GO_MOD_VENDOR_NO_PROXY}"
        export no_proxy="${GO_MOD_VENDOR_NO_PROXY}"
    fi

    cd ${GO_MOD_VENDOR_WORKDIR}

    if vendor_ok; then
        bbnote "vendor directory healthy, skipping dependency setup"
        return
    fi

    bbwarn "** use GOPROXY=${GOPROXY}, if network issues occurred, try setting GOPROXY or modify your network configs"
    if ! ${GO} mod vendor; then
        # A proxy can serve a corrupted module zip ("zip: not a valid
        # zip file") and the broken artifact then lingers in the module
        # cache, failing every rerun.  Reset the cache once and retry
        # so a poisoned cache heals itself instead of wedging builds
        # until WORKDIR is removed by hand.
        bbwarn "** go mod vendor failed, resetting module cache and retrying once"
        chmod_modcache
        rm -rf "${GOMODCACHE}"
        ${GO} mod vendor || bbfatal "go mod vendor failed after module cache reset"
    fi

    bbnote "go mod vendor finished"
}

# Go marks module cache contents read-only (files 0444, dirs 0555) to
# enforce cache immutability. bitbake's base do_clean removes WORKDIR
# with shutil.rmtree, which fails with PermissionError on those
# entries, so -c cleanall / cleansstate abort and leave the recipe
# uncleanable. Make the cache writable before WORKDIR is removed.
do_clean[prefuncs] += "chmod_modcache"
do_cleanall[prefuncs] += "chmod_modcache"
do_cleansstate[prefuncs] += "chmod_modcache"

addtask do_setup_deps after do_patch before do_compile
