# ref bb: https://git.yoctoproject.org/meta-virtualization/tree/recipes-networking/cni

OPENEULER_REPO_NAMES = "cni oee_archive"

PV = "1.2.0"

LIC_FILES_CHKSUM = "file://LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

SRC_URI = " \
        file://v1.2.0.tar.gz \
        file://0001-k3s-cni-adaptation.patch \
        file://master.zip \
        file://oee_archive/cni/v1.2.0.tar.gz \
"

S = "${WORKDIR}/plugins-${PV}"

GO_IMPORT = "vendor"

do_compile() {
	mkdir -p ${S}/src/github.com/containernetworking
	ln -sfr ${S}/vendor/github.com/containernetworking/cni ${S}/src/github.com/containernetworking/cni

	# Fixes: cannot find package "github.com/containernetworking/plugins/plugins/meta/bandwidth" in any of:
	# we can't clone the plugin source directly to where it belongs because
	# there seems to be an issue in the relocation code from UNPACKDIR to S
	# and our LICENSE file is never found.
	# This symbolic link arranges for the code to be available where go will
	# search during the build
	ln -sfr ${S}/ ${B}/src/github.com/containernetworking/plugins

    # not need from source recipes:
	# ln -sf vendor.copy vendor
	# cp ${UNPACKDIR}/modules.txt vendor/
	# cd ${B}/src/github.com/containernetworking/cni/cnitool
	# ${GO} build ${GOBUILDFLAGS}

    # reexec sync from src-openeuler -- just remain code here, current not build and pack
    mkdir -p ${S}/src/github.com/docker/docker/pkg
    ln -sfr ${WORKDIR}/reexec-master ${S}/src/github.com/docker/docker/pkg/reexec
    # flannel cmd tool
    mkdir -p ${S}/src/github.com/containernetworking/plugins/plugins/meta
    ln -sfr ${WORKDIR}/cni-plugin-1.2.0 ${S}/src/github.com/containernetworking/plugins/plugins/meta/flannel

	export GO111MODULE=off

	cd ${B}/src/github.com/containernetworking/cni/libcni
	${GO} build ${GOBUILDFLAGS}

	cd ${B}/src/github.com/containernetworking/plugins
	PLUGINS="$(ls -d plugins/meta/*; ls -d plugins/ipam/*; ls -d plugins/main/* | grep -v windows)"
	mkdir -p ${B}/plugins/bin/
	for p in $PLUGINS; do
	    plugin="$(basename "$p")"
	    echo "building: $p"
	    ${GO} build ${GOBUILDFLAGS} -ldflags '-X github.com/containernetworking/plugins/pkg/utils/buildversion.BuildVersion=${CNI_VERSION}' -o ${B}/plugins/bin/$plugin github.com/containernetworking/plugins/$p
	done 
}

do_install() {
    localbindir="${libexecdir}/cni/"

    install -d ${D}${localbindir}
    install -d ${D}/${sysconfdir}/cni/net.d
    
    # src-openeuelr not have cnitool
    # install -m 755 ${S}/src/import/cnitool/cnitool ${D}/${localbindir}

    install -m 755 -D ${B}/plugins/bin/* ${D}/${localbindir}

    # Parts of k8s expect the cni binaries to be available in /opt/cni
    install -d ${D}/opt/cni
    ln -sf ${libexecdir}/cni/ ${D}/opt/cni/bin
}
