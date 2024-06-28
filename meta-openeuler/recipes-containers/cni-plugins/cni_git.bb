HOMEPAGE = "https://github.com/containernetworking/cni"
SUMMARY = "Container Network Interface - networking for Linux containers"
DESCRIPTION = "CNI (Container Network Interface), a Cloud Native Computing \
Foundation project, consists of a specification and libraries for writing \
plugins to configure network interfaces in Linux containers, along with a \
number of supported plugins. CNI concerns itself only with network connectivity \
of containers and removing allocated resources when the container is deleted. \
Because of this focus, CNI has a wide range of support and the specification \
is simple to implement. \
"

SRCREV_cni = "b62753aa2bfa365c1ceaff6f25774a8047c896b5"
SRCREV_plugins = "b6a0e0bc96906f0d3bd6bfcaab0b5ae72292f46c"
SRCREV_flannel_plugin = "6464faacf5c00e25321573225d74638455ef03a0"
SRCREV_FORMAT = "cni_plugins"
SRC_URI = "\
	git://github.com/containernetworking/cni.git;branch=main;name=cni;protocol=https;destsuffix=${GO_SRCURI_DESTSUFFIX} \
	file://modules.txt \
	"

SRC_URI += "git://github.com/containernetworking/plugins.git;branch=main;destsuffix=${GO_SRCURI_DESTSUFFIX}/src/github.com/containernetworking/plugins;name=plugins;protocol=https"
SRC_URI += "git://github.com/flannel-io/cni-plugin;branch=main;name=flannel_plugin;protocol=https;destsuffix=${GO_SRCURI_DESTSUFFIX}/src/github.com/containernetworking/plugins/plugins/meta/flannel"

# generated via:
# ./scripts/oe-go-mod-autogen.py --repo https://github.com/containernetworking/cni.git --rev <insert your rev here>
include src_uri.inc

DEPENDS = " \
    rsync-native \
    "

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://src/import/LICENSE;md5=fa818a259cbed7ce8bc2a22d35a464fc"

GO_IMPORT = "import"
S = "${WORKDIR}/git"

PV = "v1.2.0-rc0+git${SRCREV_cni}"
CNI_VERSION = "v1.2.0"

inherit go
inherit goarch

# https://github.com/llvm/llvm-project/issues/53999
TOOLCHAIN = "gcc"

# sets the "sites" variable.
include relocation.inc

do_compile() {
	mkdir -p ${S}/src/github.com/containernetworking
	ln -sfr ${S}/src/import ${S}/src/github.com/containernetworking/cni

	# Fixes: cannot find package "github.com/containernetworking/plugins/plugins/meta/bandwidth" in any of:
	# we can't clone the plugin source directly to where it belongs because
	# there seems to be an issue in the relocation code from UNPACKDIR to S
	# and our LICENSE file is never found.
	# This symbolic link arranges for the code to be available where go will
	# search during the build
	ln -sfr ${S}/src/import/src/github.com/containernetworking/plugins ${B}/src/github.com/containernetworking

	# our copied .go files are to be used for the build
	ln -sf vendor.copy vendor

	# inform go that we know what we are doing
	cp ${UNPACKDIR}/modules.txt vendor/

	export GO111MODULE=off

	cd ${B}/src/github.com/containernetworking/cni/libcni
	${GO} build ${GOBUILDFLAGS}

	cd ${B}/src/github.com/containernetworking/cni/cnitool
	${GO} build ${GOBUILDFLAGS}

	cd ${B}/src/import/src/github.com/containernetworking/plugins
	PLUGINS="$(ls -d plugins/meta/*; ls -d plugins/ipam/*; ls -d plugins/main/* | grep -v windows)"
	mkdir -p ${B}/plugins/bin/
	for p in $PLUGINS; do
	    plugin="$(basename "$p")"
	    echo "building: $p"
	    ${GO} build ${GOBUILDFLAGS} -ldflags '-X github.com/containernetworking/plugins/pkg/utils/buildversion.BuildVersion=${CNI_VERSION}' -o ${B}/plugins/bin/$plugin github.com/containernetworking/plugins/$p
	done
}

do_compile[cleandirs] = "${B}/plugins"

do_install() {
    localbindir="${libexecdir}/cni/"

    install -d ${D}${localbindir}
    install -d ${D}/${sysconfdir}/cni/net.d

    install -m 755 ${S}/src/import/cnitool/cnitool ${D}/${localbindir}
    install -m 755 -D ${B}/plugins/bin/* ${D}/${localbindir}

    # Parts of k8s expect the cni binaries to be available in /opt/cni
    install -d ${D}/opt/cni
    ln -sf ${libexecdir}/cni/ ${D}/opt/cni/bin
}

FILES:${PN} += "${libexecdir}/cni/* /opt/cni/bin"

INSANE_SKIP:${PN} += "ldflags already-stripped"

deltask compile_ptest_base

RDEPENDS:${PN} += " ca-certificates"
