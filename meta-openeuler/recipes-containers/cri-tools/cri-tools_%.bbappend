# ref bb recipe: https://git.yoctoproject.org/meta-virtualization/tree/recipes-containers/cri-tools

PV = "1.29.0"

LIC_FILES_CHKSUM = "file://LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

# conflict with openeuler
SRC_URI:remove = " \
        file://0001-build-allow-environmental-CGO-settings-and-pass-dont.patch \
"

SRC_URI:prepend = " \
    file://v1.29.0.tar.gz \
    file://0001-fix-CVE-2024-24786.patch \
"

S = "${WORKDIR}/cri-tools-${PV}"

# source dir from src-openeuler is different from bb-upstream
do_compile() {
    export GOPATH="${S}/vendor:${STAGING_DIR_TARGET}/${prefix}/local/go"
    cd ${S}/

    # Build the target binaries
    export GOARCH="${TARGET_GOARCH}"
    # Pass the needed cflags/ldflags so that cgo can find the needed headers files and libraries
    export CGO_ENABLED="1"
    export CGO_CFLAGS="${CFLAGS} --sysroot=${STAGING_DIR_TARGET}"
    export CGO_LDFLAGS="${LDFLAGS} --sysroot=${STAGING_DIR_TARGET}"
    export CFLAGS=""
    export LDFLAGS=""
    export CC="${CC}"
    export LD="${LD}"
    export GOBIN=""

    oe_runmake crictl
}

do_install() {
    install -d ${D}${bindir}
    for f in $(find ${S}/build/bin/ -type f); do
	echo "installing $f to ${D}/${bindir}"
        install -m 755 -D $f ${D}/${bindir}
    done
}
