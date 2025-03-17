HOMEPAGE = "git://github.com/kubeedge/kubeedge;branch=master;protocol=https"
SUMMARY = "Production-Grade Container Scheduling and Management"
DESCRIPTION = "KubeEdge is built upon Kubernetes and extends native containerized \
application orchestration and device management to hosts at the Edge. \
"

PV = "1.8.0"

SRC_URI = " \
    file://v1.8.0.tar.gz;subdir=git/src/github.com/kubeedge/kubeedge;striplevel=1 \
"

SRC_URI:append = " \
    file://0001-rpminstaller-add-support-for-openEuler.patch \
    file://1000-add-riscv64-support.patch \
    file://openeuler-embedded-support-only.patch \
    file://edgecore.example.yaml \
    file://cloudcore.example.yaml \
"

DEPENDS += "rsync-native \
            coreutils-native \
            go-native \
           "

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

GO_IMPORT = "import"
S = "${WORKDIR}/git/src/github.com/kubeedge/kubeedge"

inherit systemd
inherit go
inherit goarch

do_compile() {
	export GOPATH="${S}/src/import/.gopath:${S}/src/import/vendor:${STAGING_DIR_TARGET}/${prefix}/local/go:${WORKDIR}/git/"
	cd ${S}

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
	export OEE_YOCTO_VERSION="v${PV}-oee+yocto"
    export GOLDFLAGS="-buildid=none -buildmode=pie -extldflags ' -zrelro -ftrapv -znow -static' -linkmode=external"
  
    make all CGO_FLAGS=${CGO_FLAGS} GO=${GO}
    ${GO} build -v -o _output/local/bin/csidriver  github.com/kubeedge/kubeedge/cloud/cmd/csidriver
}

export TARBALL_NAME = "${BPN}-v${PV}-linux-${TARGET_GOARCH}"
do_install() {
    # create directories
    install -d ${D}${bindir}
    install -d ${D}${sysconfdir}
    install -d ${D}${systemd_system_unitdir}/
    install -d ${D}${sysconfdir}/kubeedge
    install -d ${D}${sysconfdir}/kubeedge/config
    install -d ${D}${sysconfdir}/kubeedge/tools

    # install binaries
    install -m 755 -D ${S}/_output/local/bin/keadm ${D}/${bindir}
    install -m 755 -D ${S}/_output/local/bin/cloudcore ${D}/${bindir}
    install -m 755 -D ${S}/_output/local/bin/edgecore ${D}/${bindir}
    install -m 755 -D ${S}/_output/local/bin/admission ${D}/${bindir}
    install -m 755 -D ${S}/_output/local/bin/csidriver ${D}/${bindir}
    install -m 755 -D ${S}/_output/local/bin/edgesite-agent ${D}/${bindir}
    install -m 755 -D ${S}/_output/local/bin/edgesite-server ${D}/${bindir}

    # default configs (generated by --defaultconfig) for both cloudcore and edgecore
    install -Dpm0640 ${WORKDIR}/cloudcore.example.yaml ${D}${sysconfdir}/kubeedge/config/edgecore.example.yaml
    install -Dpm0640 ${WORKDIR}/edgecore.example.yaml ${D}${sysconfdir}/kubeedge/config/edgecore.example.yaml

    # service file for systemd
    install -m 0644 ${S}/build/tools/cloudcore.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${S}/build/tools/edgecore.service ${D}${systemd_system_unitdir}/
    # install service file in /etc/kubeedge/ as well so that no need to download from internet when they use keadm
    install -m 0644 ${S}/build/tools/cloudcore.service ${D}${sysconfdir}/kubeedge/
    install -m 0644 ${S}/build/tools/edgecore.service ${D}${sysconfdir}/kubeedge/
    sed -i 's#/usr/local/bin/edgecore#/usr/bin/edgecore#g' ${D}${sysconfdir}/kubeedge/edgecore.service

    # crd yamls for kubernetes
    install -Dm 0644 ${S}/build/crds/devices/devices_v1alpha1_devicemodel.yaml ${D}${sysconfdir}/kubeedge/crds/devices/devices_v1alpha1_devicemodel.yaml
    install -Dm 0644 ${S}/build/crds/devices/devices_v1alpha2_devicemodel.yaml ${D}${sysconfdir}/kubeedge/crds/devices/devices_v1alpha2_devicemodel.yaml
    install -Dm 0644 ${S}/build/crds/devices/devices_v1alpha1_device.yaml ${D}${sysconfdir}/kubeedge/crds/devices/devices_v1alpha1_device.yaml
    install -Dm 0644 ${S}/build/crds/devices/devices_v1alpha2_device.yaml ${D}${sysconfdir}/kubeedge/crds/devices/devices_v1alpha2_device.yaml
    install -Dm 0644 ${S}/build/crds/reliablesyncs/objectsync_v1alpha1.yaml ${D}${sysconfdir}/kubeedge/crds/reliablesyncs/objectsync_v1alpha1.yaml
    install -Dm 0644 ${S}/build/crds/reliablesyncs/cluster_objectsync_v1alpha1.yaml ${D}${sysconfdir}/kubeedge/crds/reliablesyncs/cluster_objectsync_v1alpha1.yaml
    install -Dm 0644 ${S}/build/crds/router/router_v1_ruleEndpoint.yaml ${D}${sysconfdir}/kubeedge/crds/router/router_v1_ruleEndpoint.yaml
    install -Dm 0644 ${S}/build/crds/router/router_v1_rule.yaml ${D}${sysconfdir}/kubeedge/crds/router/router_v1_rule.yaml

    # tool for certificate generation
    install -Dpm0550 ${S}/build/tools/certgen.sh ${D}${sysconfdir}/kubeedge/tools/certgen.sh

    # construct tarball used for keadm
    install -d ${D}/${TARBALL_NAME}
    install -Dpm0550 ${S}/_output/local/bin/cloudcore ${D}/${TARBALL_NAME}/cloud/cloudcore/cloudcore
    install -Dpm0550 ${S}/_output/local/bin/admission ${D}/${TARBALL_NAME}/cloud/admission/admission
    install -Dpm0550 ${S}/_output/local/bin/csidriver ${D}/${TARBALL_NAME}/cloud/csidriver/csidriver
    install -Dpm0550 ${S}/_output/local/bin/edgecore ${D}/${TARBALL_NAME}/edge/edgecore
    cp -r ${D}${sysconfdir}/kubeedge/crds/ ${D}/${TARBALL_NAME}
    echo "v${PV}" > ${D}/${TARBALL_NAME}/version
    pushd ${D}
    tar zcf ${TARBALL_NAME}.tar.gz ${TARBALL_NAME}/
    sha512sum ${TARBALL_NAME}.tar.gz | awk '{print $1}' > checksum_${TARBALL_NAME}.tar.gz.txt
    install -Dpm0550 ${TARBALL_NAME}.tar.gz ${D}${sysconfdir}/kubeedge/${TARBALL_NAME}.tar.gz
    install -Dpm0550 checksum_${TARBALL_NAME}.tar.gz.txt ${D}${sysconfdir}/kubeedge/checksum_${TARBALL_NAME}.tar.gz.txt
    popd
}

PACKAGES =+ "keadm cloudcore edgecore edgesite keadmtarball"
ALLOW_EMPTY:${PN} = "1"
RDEPENDS:${PN} += " \
        keadm \
        cloudcore \
        edgecore \
        edgesite \
"

RDEPENDS:edgecore += "mosquitto"

FILES:keadm = " \
        ${bindir}/keadm \
        ${sysconfdir}/kubeedge/cloudcore.service \
        ${sysconfdir}/kubeedge/edgecore.service \
        ${sysconfdir}/kubeedge/${TARBALL_NAME}.tar.gz \
        ${sysconfdir}/kubeedge/checksum_${TARBALL_NAME}.tar.gz.txt \
"

FILES:cloudcore = " \
        ${bindir}/cloudcore \
        ${bindir}/admission \
        ${bindir}/csidriver \
        ${systemd_system_unitdir}/cloudcore.service \
        ${sysconfdir}/kubeedge/crds \
        ${sysconfdir}/kubeedge/tools/certgen.sh \
        ${sysconfdir}/kubeedge/config/cloudcore.example.yaml \
"

FILES:edgecore = " \
        ${bindir}/edgecore \
        ${systemd_system_unitdir}/edgecore.service \
        ${sysconfdir}/kubeedge/config/edgecore.example.yaml \
"

FILES:edgesite = " \
        ${bindir}/edgesite-agent \
        ${bindir}/edgesite-server \
"

FILES:keadmtarball = "/${TARBALL_NAME}.tar.gz /checksum_${TARBALL_NAME}.tar.gz.txt /${TARBALL_NAME} "

# If board config use =y instead ko, remove it from bbappend.
RDEPENDS:edgecore += " \
        kernel-module-llc \
        kernel-module-stp \
        kernel-module-bridge \
        kernel-module-br-netfilter \
        kernel-module-libcrc32c \
        kernel-module-nf-conntrack \
        kernel-module-nf-conntrack-netlink \
        kernel-module-nfnetlink \
        kernel-module-nf-nat \
        kernel-module-vxlan \
        kernel-module-veth \
        kernel-module-nf-defrag-ipv4 \
        kernel-module-nf-defrag-ipv6 \
        kernel-module-nft-chain-nat \
        kernel-module-nft-compat \
        kernel-module-nft-counter \
        kernel-module-xt-addrtype \
        kernel-module-xt-comment \
        kernel-module-xt-conntrack \
        kernel-module-xt-mark \
        kernel-module-xt-masquerade \
        kernel-module-xt-multiport \
        kernel-module-xt-nat \
        kernel-module-xt-tcpudp \
        kernel-module-xt-connmark \
        kernel-module-xt-statistic \
        kernel-module-xt-physdev \
        kernel-module-xt-nflog \
        kernel-module-xt-limit \
"

# sync Kubernetes kernel RRECOMMENDS
RRECOMMENDS:${PN} = "\
                     kernel-module-xt-addrtype \
                     kernel-module-xt-nat \
                     kernel-module-xt-multiport \
                     kernel-module-xt-conntrack \
                     kernel-module-xt-comment \
                     kernel-module-xt-mark \
                     kernel-module-xt-connmark \
                     kernel-module-vxlan \
                     kernel-module-xt-masquerade \
                     kernel-module-xt-statistic \
                     kernel-module-xt-physdev \
                     kernel-module-xt-nflog \
                     kernel-module-xt-limit \
                     kernel-module-nfnetlink-log \
"

deltask compile_ptest_base
