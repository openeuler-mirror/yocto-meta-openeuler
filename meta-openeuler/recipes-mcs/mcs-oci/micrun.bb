SUMMARY = "Containerd shim-v2 runtime for the MCS runtime (micrun)"
DESCRIPTION = "Micrun integrates the mixed-criticality OCI runtime with container engine \
through a shimv2 implementation tailored for openEuler Embedded."
HOMEPAGE = "https://gitee.com/openeuler/mcs"

LICENSE = "MulanPSL-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=74b1b7a7ee537a16390ed514498bf23c"

# container CE requirements
# TODO: after DISTRO_FEATURES "containers" established well, replace "containerd" with "containers"
REQUIRED_DISTRO_FEATURES += " mcs containerd "

SRCREV = "5c64255ab80a8dc2641699dd8d8076c95fef6b84"
PV = "0.1-nightly-git-${SRCREV}"

OPENEULER_LOCAL_NAME = "mcs"
SRC_URI = "file://mcs"

S = "${WORKDIR}/mcs"
MICRUN_SRC = "${S}/micrun-go"
do_fetch[depends] += "mcs-linux:do_fetch"

inherit go
inherit goarch
inherit features_check
inherit deploy

GO_IMPORT = "micrun"

MICRUN_BIN ?= "containerd-shim-mica-v2"
MICRUN_LINK ?= "micrun"
MICRUN_SHIM_NAME ?= "io.containerd.mica.v2"
GOBUILD_MODE ?= "online"
vendor_dir="${MICRUN_SRC}/vendor"

python __anonymous () {
    if not bb.utils.contains('MCS_FEATURES', 'micrun', True, False, d):
        bb.parse.SkipRecipe("enable micrun via MCS_FEATURES to build this recipe")
}


GO_EXTRA_LDFLAGS += "-X main.ShimName=${MICRUN_SHIM_NAME} -s -w"
#GOPATH="${MICRUN_SRC}:${MICRUN_SRC}/vendor.move:${STAGING_DIR_TARGET}/${prefix}/local/go:${MICRUN_SRC}/src/import/.gopath"
GOMODCACHE="${MICRUN_SRC}/pkg/mod"



# NOTICE: why not use go mod -modcacherw?
# 1. go mod -modcacherw requires go mod building instead of vendor building
#    vendor mode is recommended
# 2. chmod_modcache hooks + setup_deps() can do more things than go mod -modcacherw
chmod_modcache() {
    if [ -d "${GOMODCACHE}" ]; then
        chmod -R u+rwX,go+rwX "${GOMODCACHE}"
    fi

    if [ -d "${B}/pkg" ]; then
        chmod -R u+rwX,go+rwX "${B}/pkg" "${MICRUN_SRC}/vendor"
        bbnote "change permission for current pkg directory"
    fi
}

vendor_ok() {
    if [ ! -d "${vendor_dir}" ]; then
        bbnote "** ${PN} vendor directory missing, refreshing dependencies"
        return 1
    fi
    (
        GO111MODULE=on GOFLAGS="-mod=vendor" ${GO} list ./... >/dev/null 2>&1
    )
    rc=$?
    if [ ${rc} -ne 0 ]; then
        bbwarn "** vendor directory validation failed"

        return ${rc}
    fi

    (
        GO111MODULE=on GOFLAGS="-mod=vendor" ${GO} mod verify >/dev/null 2>&1
    )
    rc=$?
    if [ ${rc} -ne 0 ]; then
        bbwarn "vendor directory verification failed"
    fi
    return ${rc}
}

# ensure cached go vendor directory rw permissions are set correctly
do_setup_deps[prefuncs] = "chmod_modcache"
do_setup_deps[postfuncs] = "chmod_modcache"
do_setup_deps[network] = "1"
do_setup_deps() {
  export GO111MODULE=on
  export CGO_ENABLED=0
  export GOARCH=${TARGET_ARCH}
  export GOBUILDFLAGS="${GO_EXTRA_LDFLAGS}"
  export GOPROXY="${MICRUN_GOPROXY}"
  cd ${MICRUN_SRC}
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
    export GO111MODULE=on
    export CGO_ENABLED=0
    export GOARCH=${TARGET_ARCH}
    export GOBUILDFLAGS="${GO_EXTRA_LDFLAGS}"
    # ensure previous pkg cache is writable before we clear it
    chmod_modcache
    rm -rf ${B}/pkg
    cd ${MICRUN_SRC}
    install -d ${B}/bin
    ${GO} build -mod=vendor ${GOBUILDFLAGS} -o ${B}/bin/${MICRUN_BIN} .
}

script_dir="/opt/${PN}"
do_install() {
    install -d ${D}${bindir}
    install -d ${D}${script_dir}
    install -m 0755 ${B}/bin/${MICRUN_BIN} ${D}${bindir}/${MICRUN_BIN}
    builder_dir="${MICRUN_SRC}/scripts/mica-image-builder"
    cp ${builder_dir}/mica-image-builder.py ${D}${script_dir}
    cp ${builder_dir}/mica_label_manager.py ${D}${script_dir}
    cp ${builder_dir}/mica-labels.toml ${D}${script_dir}
    cp ${builder_dir}/requirements.txt ${D}${script_dir}
}

PACKAGES:append = " ${PN}-scripts"
FILES:${PN} += "${bindir}/${MICRUN_BIN}"
FILES:${PN}-scripts += "${script_dir}"
INHIBIT_PACKAGE_STRIP = "1"
INSANE_SKIP:${PN} += "ldflags already-stripped"

# install util scripts to deploy directory for copying to output dir
do_deploy() {
    install -d ${DEPLOYDIR}/micrun-scripts
    cp -rfp ${D}${script_dir}/* ${DEPLOYDIR}/micrun-scripts/
}
addtask deploy after do_install
