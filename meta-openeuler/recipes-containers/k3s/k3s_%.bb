SUMMARY = "Production-Grade Container Scheduling and Management"
DESCRIPTION = "Lightweight Kubernetes, intended to be a fully compliant Kubernetes."
HOMEPAGE = "https://k3s.io/"
LICENSE = "Apache-2.0"
S = "${WORKDIR}/${BP}"
LIC_FILES_CHKSUM = "file://${WORKDIR}/${BP}/LICENSE;md5=2ee41112a44fe7014dce33e26468ba93"

#PV = "v1.24.5-rc1+k3s2"
# 实际上PV=v1.24.12-rc1+k3s1, v1.22.17这个名字只是调试用, k3s release page=31
PV = "v1.22.17+k3s1"

#file://0001-Finding-host-local-in-usr-libexec.patch;patchdir=src/import  
#git://github.com/k3s-io/k3s.git;branch=release-1.22;name=k3s;protocol=https 

do_compile[network] = "1"
SRC_URI = " \ 
           file://${PN}-${PV}.tar.gz \
           file://k3s-agent.service \
           file://k3s.service \
           file://k3s-agent \
           file://k3s-kill-agent \
           file://cni-containerd-net.conf \
           file://k3s-killall.sh \
           file://modules.txt \
           file://k3s-arm64-${PV} \ 
           file://k3s-airgap-images-arm64.tar.gz;unpack=0 \
           file://k3s-install-agent \
           file://install.sh \
           file://k3s-rootless.service \
"

include src_uri.inc

inherit go
inherit goarch
inherit systemd
#inherit cni_networking

PACKAGECONFIG = ""
GO_IMPORT = "import"
full_k3s = "true"
isulad_as_endpoint = "true"
PKG = "github.com/k3s-io/k3s"
PKGCOMMIT = "3ed243d"
#PKGCOMMIT = "3d82902b" from k3s-io upstream
VERSION_FLAGS = " \
  -X ${PKG}/pkg/version.Version=${PV} \
  -X ${PKG}/pkg/version.GitCommit=${PKGCOMMIT} \
"

STATIC_FLAGS = " -extldflags '-static' "
GO_BUILD_LDFLAGS = " ${VERSION_FLAGS}  -w -s  ${STATIC_FLAGS} "
#GO_BUILD_LDFLAGS = " ${VERSION_FLAGS}  -w -s  "
BIN_PREFIX ?= "${exec_prefix}/local"
k3s_bindir = "${exec_prefix}/bin"
build_bindir = "${S}/bin"
inherit features_check
REQUIRED_DISTRO_FEATURES = "seccomp"
VENDOR_FETCHDIR = "${S}/src/import/.gopath/pkg/mod"
DEPENDS += "rsync-native \
            coreutils-native \
            go-native \
"
export GOPROXY="https://goproxy.cn,direct"

do_compile() {

        # TODO: build CNI
        # TODO: build RUNC

        # build K3S binary 
        #export GOFLAGS="-mod=vendor"
        export GOPATH="${S}/src/import/.gopath:${S}/src/import/vendor:${STAGING_DIR_TARGET}/${prefix}/local/go"
        export CGO_ENABLED="1"
        export CGO_CFLAGS="${CFLAGS} --sysroot=${STAGING_DIR_TARGET}"
        export CGO_LDFLAGS="${LDFLAGS} --sysroot=${STAGING_DIR_TARGET}"
        export CFLAGS=""
        export GO111MODULES="on"
        export LDFLAGS=" -w -s"
        export STATIC=" -extldflags '-static' "
        export STATIC_SQLITE=" -extldflags '-static -lm -ldl -lz -lpthread' "
        export CC="${CC}"
        export LD="${LD}"
        export OEE_YOCTO_VERSION="${PV}-oee+yocto"
        #export BUILD_TAGS="static_build,ctrd,no_btrfs,netcgo,osusergo,providerless"
        export BUILD_TAGS="ctrd,apparmor,seccomp,no_btrfs,netcgo,osusergo,providerless"

        mkdir -p "${S}/src/import/vendor"
        cd ${S}/src/import

        # these are bad symlinks, go validates them and breaks the build if they are present
        rm -f vendor/go.etcd.io/etcd/client/v3/example_*
        rm -f vendor/go.etcd.io/etcd/client/v3/concurrency/example_*.go

        mkdir -p "${build_bindir}"

        # clean previous binaries
        rm -f "${build_bindir}/k3s-agent"
        rm -f "${build_bindir}/k3s-server"
        rm -f "${build_bindir}/k3s-etcd-snapshot"
        rm -f "${build_bindir}/k3s-secrets-encrypt"
        rm -f "${build_bindir}/k3s-certificate"
        rm -f "${build_bindir}/k3s-completion"
        rm -f "${build_bindir}/kubectl"
        rm -f "${build_bindir}/crictl"
        rm -f "${build_bindir}/containerd"
        rm -f "${build_bindir}/containerd-shim"
        rm -f "${build_bindir}/containerd-shim-runc-v2"
        rm -f "${build_bindir}/runc"

        cd ${S}
        if [ "${full_k3s}" = "true" ]; then
          ${GO} build -tags "static_build,no_btrfs,ctrd,netcgo,osusergo,providerless"  -ldflags "${GO_BUILD_LDFLAGS}" -trimpath -v -o ${build_bindir}/k3s ./cmd/server/main.go 2> ${WORKDIR}/temp/build_info
        else
          ${GO} build -tags "static_build,no_btrfs,ctrd,netcgo,osusergo,providerless"  -ldflags "${GO_BUILD_LDFLAGS}" -trimpath -v -o ${build_bindir}/k3s ./cmd/agent/main.go 2> ${WORKDIR}/temp/build_info
        fi
}

do_install() {

        # make needed dirs
        install -d "${D}${k3s_bindir}"
        install -d "${D}${sysconfdir}"
        install -d "${D}${sysconfdir}/k3s"
        install -d "${D}${sysconfdir}/k3s/config"
        install -d "${D}${sysconfdir}/k3s/tools"


        # install binaries
        if [ ! -f "${build_bindir}/k3s" ]; then
          echo "${build_bindir}/k3s does not exist, use a prebuild standard binary as alternative."
          if [ -f "${WORKDIR}/k3s" ]; then
            mv "${WORKDIR}/k3s-arm64-${PV}" "${build_bindir}/k3s"
          else
            echo "missing prebuild binary"
            exit -1
          fi
        fi

        install -m 755 "${build_bindir}/k3s" "${D}${k3s_bindir}"
        install -m 755 "${WORKDIR}/k3s-kill-agent" "${D}${k3s_bindir}"


        # next commit : remove full_k3s, support k3s agent only and make binary smaller
        if [ "${full_k3s}" = "true" ]; then
          #crictl conflicts
          #ln -sr "${D}${k3s_bindir}/k3s" "${D}${k3s_bindir}/crictl"
          ln -sr "${D}${k3s_bindir}/k3s" "${D}${k3s_bindir}/ctr"
          ln -sr "${D}${k3s_bindir}/k3s" "${D}${k3s_bindir}/kubectl"
          #ln -sr "${D}${k3s_bindir}/k3s" "${D}${k3s_bindir}/k3s-agent"
          ln -sr "${D}${k3s_bindir}/k3s" "${D}${k3s_bindir}/k3s-server"
          ln -sr "${D}${k3s_bindir}/k3s" "${D}${k3s_bindir}/k3s-completion"
          ln -sr "${D}${k3s_bindir}/k3s" "${D}${k3s_bindir}/k3s-certificate"
          ln -sr "${D}${k3s_bindir}/k3s" "${D}${k3s_bindir}/k3s-secrets-encrpyt"
          # etcd does not well work in some k3s at lower version 
          #ln -sr "${D}${k3s_bindir}/k3s" "${D}${k3s_bindir}/k3s-etcd-snapshot"
          install -m 755 "${WORKDIR}/k3s-killall.sh" "${D}${k3s_bindir}"
        fi
        install -m 755 "${WORKDIR}/k3s-agent" "${D}${k3s_bindir}"

        # install script for tests
        install -D -m 755 "${WORKDIR}/k3s-install-agent" "${D}${k3s_bindir}/k3s-install-agent"

        # install airgap container images
        install "${WORKDIR}/k3s-airgap-images-arm64.tar.gz" "${D}${sysconfdir}/k3s/tools"

        # install systemd services unit files
        systemd_launched=${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}
        if [ "$systemd_launched" = "true" ]; then
          unitfile_destdir="${D}${sysconfdir}/systemd/system"
          install -d "${unitfile_destdir}"
          if [ "${full_k3s}" = "true" ]; then
            install -D -m 0644 "${WORKDIR}/k3s.service" "${unitfile_destdir}/k3s.service"
            sed -i "s#\(Exec\)\(.*\)=\(.*\)\(k3s\)#\1\2=${k3s_bindir}/\4#g"  "${unitfile_destdir}/k3s.service"
          fi

          install -D -m 0644 "${WORKDIR}/k3s-agent.service" "${unitfile_destdir}/k3s-agent.service"
          sed -i "s#\(Exec\)\(.*\)=\(.*\)\(k3s\)#\1\2=${k3s_bindir}/\4#g"  "${unitfile_destdir}/k3s-agent.service"
         if [ "${isulad_as_endpoint}" = "true" ]; then
          sed -i "s#^ExecStart=\(.*\)#ExecStart=\1\n\t --container-runtime-endpoint unix:///var/run/isulad.sock #" "${unitfile_destdir}/k3s-agent.service"
          sed -i "s#Requires=containerd.service#Requires=isulad.service#g" "${unitfile_destdir}/k3s.service"
          sed -i "s#After=containerd.service*#After=isulad.service#" "${unitfile_destdir}/k3s.service"
         fi

        else
          echo "Systemd-free k3s hasn't implemented!" 
          install -d "${D}${sysconfdir}/init.d"
          install -d ${D}${sysconfdir}/rcS.d
          exit -1
        fi
}



FULL_K3S_FILES = " \
  ${k3s_bindir}/crictl \
  ${k3s_bindir}/kubectl \
  ${k3s_bindir}/ctr \
  ${k3s_bindir}/k3s-secrets-encrypt \
  ${k3s_bindir}/k3s-certificate \
  ${k3s_bindir}/k3s-server \
  ${k3s_bindir}/k3s-agent \
  ${k3s_bindir}/k3s-install-agent \
  ${k3s_bindir}/k3s-kill-agent \
  ${k3s_bindir}/k3s-killall.sh \
  ${unitfile_destdir}/k3s.service \
"

FILES:${PN} += " \
  ${unitfile_destdir}/k3s-agent.service \
  ${bb.utils.contains('full_k3s', 'true', '${FULL_K3S_FILES}', '', d)} \
   \
"

SYSTEMD_SERVICE:${PN} = "k3s-agent.service \ 
  k3s.service \
"
#SYSTEMD_AUTO_ENABLE:${PN} = "enable"
RDEPENDS:${PN} = " \ 
  conntrack-tools  \
  coreutils  \
  findutils  \
  iptables  \
  iproute2 \
  ${@bb.utils.contains('USE_PREBUILD_SHIM_V2', '1', 'lib-shim-v2-bin', 'lib-shim-v2', d)} \
"

RDEPENDS:${PN} = " \
        kernel-module-stp \
        kernel-module-bridge \
        kernel-module-libcrc32c \
        kernel-module-nf-conntrack \
        kernel-module-nf-nat \
        kernel-module-nf-defrag-ipv4 \
        kernel-module-nf-defrag-ipv6 \
        kernel-module-xt-addrtype \
        kernel-module-xt-comment \
        kernel-module-xt-nat \
        kernel-module-xt-tcpudp \
        kernel-module-br-netfilter \
        kernel-module-veth \
        kernel-module-iptable-mangle \
        kernel-module-ip6table-mangle \
"

RRECOMMEND:${PN} = "\
        kernel-module-vxlan \
        kernel-module-nf-conntrack-netlink \
        kernel-module-nfnetlink-log \
        kernel-module-nft-chain-nat \
        kernel-module-nft-compat \
        kernel-module-nft-counter \
        kernel-module-xt-nflog \
        kernel-module-xt-conntrack \
        kernel-module-xt-mark \
        kernel-module-xt-limit \
        kernel-module-xt-masquerade \
        kernel-module-xt-multiport \
        kernel-module-xt-connmark \
        kernel-module-xt-statistic \
        kernel-module-xt-physdev \
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
                     kernel-module-nfnetlink  \
                     "


INHIBIT_PACKAGE_STRIP = "1"
INSANE_SKIP:${PN} += "ldflags already-stripped"



