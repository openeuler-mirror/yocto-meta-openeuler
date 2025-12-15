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
GOBUILD_MODE ?= "vendor"

python __anonymous () {
    if not bb.utils.contains('MCS_FEATURES', 'micrun', True, False, d):
        bb.parse.SkipRecipe("enable micrun via MCS_FEATURES to build this recipe")
}


GO_EXTRA_LDFLAGS += "-X main.ShimName=${MICRUN_SHIM_NAME} -s -w"
GOPATH="${MICRUN_SRC}:${MICRUN_SRC}/vendor.move:${STAGING_DIR_TARGET}/${prefix}/local/go:${MICRUN_SRC}/src/import/.gopath"

do_compile() {
    export GO111MODULE=on
    export CGO_ENABLED=0
    export GOARCH=${TARGET_ARCH}
    export GOBUILDFLAGS="${GO_EXTRA_LDFLAGS}"

    export GOPROXY="${MICRUN_GOPROXY}"
    bbwarn "GOPROXY=${GOPROXY}"
    cd ${MICRUN_SRC}
    if [ "$GOBUILD_MODE" = "vendor" ]; then
      mkdir -p vendor.move/src
      cp -r vendor/* vendor.move/src
      GOBUILDFLAGS="${GOBUILDFLAGS} -mod=vendor"
    fi
    install -d ${B}/bin

    ${GO} build ${GOBUILDFLAGS} -o ${B}/bin/${MICRUN_BIN} .
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
