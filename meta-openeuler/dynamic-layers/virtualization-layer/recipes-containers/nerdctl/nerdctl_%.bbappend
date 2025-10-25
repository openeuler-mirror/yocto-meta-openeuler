PV = "v2.0.0-beta.v1"
SRCREV_nerdcli = "265d6b9cf526ce7d9ed8d34a0e3c3066901cc463"

#FILESEXTRAPATHS := "${THISDIR}:__default"
FILESEXTRAPATHS:prepend = "${THISDIR}:"

SRC_URI = "\ 
    git://github.com/containerd/nerdctl.git;name=nerdcli;branch=main;protocol=https \
    file://0001-Makefile-allow-external-specification-of-build-setti.patch \
    file://modules.txt \
 "
include relocation.inc
include src_uri.inc

PIEFLAG = "${@bb.utils.contains('GOBUILDFLAGS', '-buildmode=pie', '-buildmode=pie', '', d)}"

do_compile() {
    cd ${S}/src/import
	export GOPATH="$GOPATH:${S}/src/import/.gopath"

	# Pass the needed cflags/ldflags so that cgo
	# can find the needed headers files and libraries
	export GOARCH=${TARGET_GOARCH}
	export CGO_ENABLED="1"
	export CGO_CFLAGS="${CFLAGS} --sysroot=${STAGING_DIR_TARGET}"
	export CGO_LDFLAGS="${LDFLAGS} --sysroot=${STAGING_DIR_TARGET}"
    export GOFLAGS="-mod=vendor -trimpath ${PIEFLAG}"
    ln -sf vendor.copy vendor
    cp ${WORKDIR}/modules.txt vendor/
    oe_runmake GO=${GO} BUILDTAGS="${BUILDTAGS}" binaries
}

