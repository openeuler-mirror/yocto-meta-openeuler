SUMMARY = "Production-Grade Container Scheduling and Management"
DESCRIPTION = "Lightweight Kubernetes, intended to be a fully compliant Kubernetes."
HOMEPAGE = "https://k3s.io/"
LICENSE = "Apache-2.0"
S = "${WORKDIR}/${BP}"
LIC_FILES_CHKSUM = "file://${WORKDIR}/${BP}/LICENSE;md5=2ee41112a44fe7014dce33e26468ba93"
APPEND += " cgroup_no_v1=all"

PV = "v1.22.17"

python() {
  if d.getVar('TUNE_PKGARCH') == 'aarch64':
    d.setVar('ARCH', 'arm64')
  elif d.getVar('TUNE_PKGARCH') == 'x86_64':
    d.setVar('ARCH', 'amd64')
  else:
    d.setVar('ARCH', d.getVar('TUNE_PKGARCH'))
}

#file://0001-Finding-host-local-in-usr-libexec.patch;patchdir=src/import  

do_compile[network] = "1"
SRC_URI = "\ 
           file://${BP}.tar.gz \
           file://k3s-agent.service \
           file://k3s.service \
           file://k3s-kill-agent \
           file://k3s-killall.sh \
           file://modules.txt \
           file://k3s-${ARCH}-${PV} \ 
           file://k3s-install-agent \
           file://install.sh \
           file://k3s-rootless.service \
"

#include src_uri.inc

inherit go
inherit goarch
inherit systemd
inherit features_check

PACKAGECONFIG = ""
GO_IMPORT = "import"
full_k3s ?= "true"
# runtime_endpoint: isulad => isulad, embedded => k3s-embedded containerd, others
container_runtime_endpoint ?= "isulad"
PKG = "github.com/k3s-io/k3s"
PKG_CONTAINERD="github.com/containerd/containerd"
PKG_K3S_CONTAINERD="github.com/k3s-io/containerd"
PKG_CRICTL="github.com/kubernetes-sigs/cri-tools/pkg"
PKG_K8S_BASE="k8s.io/component-base"
PKG_K8S_CLIENT="k8s.io/client-go/pkg"
PKG_CNI_PLUGINS="github.com/containernetworking/plugins"

# PKG = "github.com/k3s-io/k3s"
# PKG_CONTAINERD = "github.com/containerd/containerd"
# PKG_K3S_CONTAINERD = "github.com/k3s-io/containerd"
# PKG_CRICTL = "github.com/kubernetes-sigs/cri-tools/pkg"
# PKG_K8S_BASE = "k8s.io/component-base"
# PKG_K8S_CLIENT = "k8s.io/client-go/pkg"
# PKG_CNI_PLUGINS = "github.com/containernetworking/plugins"
COMMIT = "9c3769d"
#COMMIT = "3ed243d"
#COMMIT = "3d82902b" from k3s-io upstream

# because of the limits of variable expansion in shell-style function, 
# set k3s-building flags inside `do_compile` is troublesome
VERSION_FLAGS="\
  -X ${PKG}/pkg/version.Version=${PV} \
  -X ${PKG}/pkg/version.GitCommit=${COMMIT} \
"

STATIC = " -extldflags '-static' "
# `-lz` : adding zlib to sysroot
STATIC_SQLITE = " -extldflags '-static -lm -lz -ldl -lpthread' "
K3S_LDFLAGS = " ${VERSION_FLAGS} -w -s"

# tags
# BASIC = "ctrd,seccomp,no_btrfs,netcgo,osusergo,providerless"
BASIC = "no_btrfs,ctrd,netcgo,osusergo,providerless"
SELINUX = "selinux"
APPARMOR = "apparmor"
STATIC_TAG = "static_build"
SECCOMP = "seccomp"
SQLITE_TAG = "${STATIC_TAG},libsqlite3"
TAGS = "${BASIC}"

# TODO fix compilation abortion when applied sqlite to k3s server compilation
SERVER_LDFLAGS = "${K3S_LDFLAGS} ${STATIC_SQLITE}"
AGENT_LDFLAGS = "${K3S_LDFLAGS} ${STATIC}"
SERVER_TAGS = "${TAGS}"
AGENT_TAGS = "${TAGS}"

AGENT_TAGS .= ",${STATIC_TAG},${APPARMOR}"

k3s_bindir = "${exec_prefix}/bin"
build_dir = "${S}/build"
build_bindir = "${build_dir}/bin/${BPN}"
build_srcdir = "${build_dir}/pkg/mod"
vendor_path = "${S}/vendor"
modules_path = "${S}/modules"
REQUIRED_DISTRO_FEATURES = "seccomp"
DEPENDS += "\
    rsync-native \
    coreutils-native \
    go-native \
    zlib \
"
export GOPROXY="https://goproxy.cn,direct"


do_compile() {

        #build K3S binary
        # go module will cache module@ver under the dir: vendor_gopath/pkg/mod
        # I use vendor dir under the module mod for convinence, but it is a confussing action
        # TODO: module is module, vendor is vendor.
        # download path:
        #   go mod vendor => ${S}/vendor/sites/packages
        #   GO111MODULE=on => ${S}/vendor/pkg/mod/sites/packages
        export CGO_ENABLED="1"
        export GO111MODULE=on
        export _GOPATH=${GOPATH}
        export GOPATH="${modules_path}:${vendor_path}:${STAGING_DIR_TARGET}/${prefix}/lib64/go"
        export CGO_CFLAGS="${CFLAGS} --sysroot=${STAGING_DIR_TARGET}"
        export CGO_LDFLAGS="${LDFLAGS} --sysroot=${STAGING_DIR_TARGET}"
        export CFLAGS=""
        export LDFLAGS=" -w -s"
        export CC="${CC}"
        export LD="${LD}"
        export OEE_YOCTO_VERSION="${PV}-oee+yocto"

        cd "${S}"
        # mkdir -p "${vendor_path}"
        mkdir -p "${modules_path}"
        mkdir -p "${build_bindir}"
        mkdir -p "${WORKDIR}/build/pkg/mod"

        # if [ ! -e "${vendor_path}" ]; then
          # ${GO} mod vendor 2> ${WORKDIR}/temp/k3s_vendor_info
        # fi

        # useless building scripts
        rm -f "Dockerfile.*"
        # GO will find same package in both recipes-sysroot and vendor dir.
        # pointing modules/pkg/mod/src to vendor dir
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
        rm -rf "${builds}/data"

        # TODO: fixing linking warnings
        #  * warning: Using 'dlopen' in statically linked applications requires at runtime the shared libraries from the glibc version used for linking
        #  * warning: Using 'getaddrinfo' in statically linked applications requires at runtime the shared libraries from the glibc version used for linking
        # NOTICE In k3s version 1.22 and later, k3s-io has removed the building for the 
        # standalone k3s-agent binary, resulting in an increase of a little in the binary size.
        # both two products are stored in /var/lib/rancher/k3s/data/SomeHash/bin
        if [ "${full_k3s}" = "true" ]; then
          ${GO} build  -mod=readonly -tags "${SERVER_TAGS}"  -ldflags "${SERVER_LDFLAGS}" \
            -trimpath -v -o ${build_bindir}/containerd ./cmd/server/main.go \
              2> ${WORKDIR}/temp/k3s_build_info
        else
          ${GO} build -mod=readonly -tags "${AGENT_TAGS}"  -ldflags "${AGENT_LDFLAGS}" \
            -trimpath -v -o ${build_bindir}/k3s-agent ./cmd/agent/main.go \
              2> ${WORKDIR}/temp/k3s_build_info
        fi

        # make sure cached package tree modificable without 'Permission Denided'
        chmod 777 -R "${modules_path}/pkg/mod"
        chmod 777 -R "${WORKDIR}/build/pkg/mod"

        # TODO move them into containerd recipe instead.
        # build_runc
        # build_containerd_shim_runc_v2

        # ? 如果要构建非 isulad 作runtime的k3s,就需要把 vendor和module混用起来。
        # 1. 不希望在do_compile时重复拉取依赖。
        # 2. 其他组件多数是vendor构建的。
        # bbfatal "stop"
        # ${GO} generate
        export GO111MODULE=off
        # FATAL: 
        #   cmd/k3s/main.go:181:16: undefined: data.AssetNames
        #   cmd/k3s/main.go:218:23: undefined: data.Asset
        # under ${S}, pkg/data/data.go is empty indeed
        # ?? 位于${S}下，编译会出现上面的错误
        # 源码是从 FROM=yocto-meta-openeuler/../k3s 获取,复制到${S}
        # 在FROM编译，则没有问题；
        # 使用sysroot-native的go, host的go,都一样
        # 从${FROM}前往${S}, 失败，从${S}返回到${FROM}, 成功, 
        # CGO_ENABLED=0 ${GO} build -tags "urfave_cli_no_docs" -ldflags "${K3S_LDFLAGS} ${STATIC}"\
        # -v -o "${PN}-${ARCH}" ./cmd/k3s/main.go  2> ${WORKDIR}/temp/cli_build_info
        # 手动加打印也确认了用的是pkg/data/data.go
}

build_runc() {
  RUNC_TAGS="${APPARMOR},${SECCOMP}"
  RUNC_STATIC="static"
  # go vendor build.
  bbplain "[INFO] Building runc"
  CGO_ENABLE=0 GO111MODULE=off make GOPATH=${build_dir} EXTRA_LDFLAGS=" -w -s" BUILDTAGS="$RUNC_TAGS" \
    -C "${vendor_path}/github.com/opencontainers/runc" ${RUNC_STATIC}
  cp -f "${vendor_path}/github.com/opencontainers/runc/runc" ${build_bindir}/runc
}

build_containerd_shim() {
  bbplain "Building containerd-shim"
  rm -r "${build_bindir}/containerd-shim"
  cd "${vendor_path}"
  CGO_ENABLE=0 GO111MODULE=off make -C ./github.com/containerd/containerd  bin/containerd-shim
  cp -f ./github.com/containerd/containerd/bin/containerd-shim  ${build_bindir}/containerd-shim
}

build_containerd_shim_runc_v2() {
  bbplain "Building containerd-shim-runc-v2"
  rm -r "${build_bindir}/containerd-shim-runc-v2"
  cd "${modules_path}"
  # CGO_ENABLE=0 GO111MODULE=off make -C ./github.com/containerd/containerd  bin/containerd-shim-runc-v2
  CGO_ENABLE=0 GO111MODULE=off make -C "./github.com/k3s-io/containerd@*"/cmd/containerd-shim-runc-v2 bin/containerd-shim-runc-v2
  cp -f ./github.com/containerd/containerd/bin/containerd-shim-runc-v2 ${build_bindir}/containerd-shim-runc-v2
}

# compress and make a multicall binary (a single binary contains bunches of subprocess)
do_multicall() {
  # mkdir -p "${build_dir}/data ${build_dir}/out"
  # mkdir -p "${S}/dist/artifacts"

  # tar cvf "${build_dir}/out/data.tar" "${build_dir}" 
  # zstd --no-progress -T0 -16 -f --long=25 --rm "${build_dir}/out/data.tar.zst"
  # HASH=$(sha256sum "${build_dir}/out/data.tar.zst" | awk '{print $1}')
  # cp "${build_dir}/out/data.tar.zst" "${build_dir}/data/${HASH}.tar.zst"

  # build multicall k3s binary, this is what will be installed into usr/bin
  bbplain "[INFO] multicall built"
}

addtask do_multicall after do_compile before do_install


do_airgap() {
  bbfatal "it is super troublesome to build airgap images in the oebuild docker environment, \
    if you wanna build k3s airgap image manually, you should run \
    `bitbake k3s-airgap` in the **native host** outside oebuild docker environment"
}

# addtask do_airgap after do_multicall before do_install

do_install() {

        install -d "${D}${k3s_bindir}"
        install -d "${D}${sysconfdir}"
        install -d "${D}${sysconfdir}/k3s"
        install -d "${D}${sysconfdir}/k3s/config"
        # airgap images for isulad will installed here
        install -d "${D}${sysconfdir}/k3s/tools"
        install -d "${D}${sysconfdir}/k3s/tools"
        # install dir for airgap images when use embedded containerd as endpoint
        install -d "${D}${localstatedir}/lib/rancher/k3s/agent/images"


        bbplain "container runtime endpoint = ${container_runtime_endpoint}"
        bbplain "full_k3s = ${full_k3s}"

        # install binaries
        # only if `-k` option is passed, the search for talternatives works after the failure of do_compile
        # you should add k3s prebuild binary to SRC_URI
        if [ ! -f "${build_bindir}/containerd" ] && \
          [ ! -f "${build_bindir}/k3s" ] && \
          [ -f "${WORKDIR}/k3s"]; then
          echo "in ${build_bindir} products does not exist, use a prebuild standard binary as alternative."
          if [ -f "${WORKDIR}/k3s-${ARCH}-${PV}" ]; then
            mv "${WORKDIR}/k3s-${ARCH}-${PV}" "${build_bindir}/k3s"
          else
            echo "missing prebuild binary"
            exit -1
          fi
        fi
      
        install -m 755 "${WORKDIR}/k3s-kill-agent" "${D}${k3s_bindir}"
        # check-config, which is temporaliy useless for oee because currently oee image 
        # is production-level, does not contain a config file in rootfs
        install -m 755 "${S}/contrib/util/check-config.sh" "${D}${k3s_bindir}/check-config"

        # next commit : remove full_k3s, support k3s agent only and make binary smaller
        if [ "${full_k3s}" = "true" ]; then
          install -m 755 "${build_bindir}/containerd" "${D}${k3s_bindir}"
          #TODO crictl conflicts
          #ln -sr "${D}${k3s_bindir}/containerd" "${D}${k3s_bindir}/crictl"
          ln -sr "${D}${k3s_bindir}/containerd" "${D}${k3s_bindir}/ctr"
          ln -sr "${D}${k3s_bindir}/containerd" "${D}${k3s_bindir}/kubectl"
          ln -sr "${D}${k3s_bindir}/containerd" "${D}${k3s_bindir}/k3s-agent"
          ln -sr "${D}${k3s_bindir}/containerd" "${D}${k3s_bindir}/k3s-server"
          ln -sr "${D}${k3s_bindir}/containerd" "${D}${k3s_bindir}/k3s-completion"
          ln -sr "${D}${k3s_bindir}/containerd" "${D}${k3s_bindir}/k3s-certificate"
          ln -sr "${D}${k3s_bindir}/containerd" "${D}${k3s_bindir}/k3s-secrets-encrpyt"
          # etcd does not well work in some k3s at lower version
          #ln -sr "${D}${k3s_bindir}/k3s" "${D}${k3s_bindir}/k3s-etcd-snapshot"
          install -m 755 "${WORKDIR}/k3s-killall.sh" "${D}${k3s_bindir}"
        else
          install -m 755 "${build_bindir}/k3s-agent" "${D}${k3s_bindir}"
        fi
        install -D -m 755 "${WORKDIR}/install.sh" "${D}${k3s_bindir}/k3s-official-install"

        # install script for tests
        install -D -m 755 "${WORKDIR}/k3s-install-agent" "${D}${k3s_bindir}/k3s-install-agent"


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

          if [ "${container_runtime_endpoint}" = "isulad" ]; then
            install "${WORKDIR}/k3s-airgap-images-arm64.tar.gz" "${D}${sysconfdir}/k3s/tools"
            sed -i "s#^ExecStart=\(.*\)#ExecStart=\1\n\t --container-runtime-endpoint unix:///var/run/isulad.sock #" "${unitfile_destdir}/k3s-agent.service"
            sed -i "s/^Documentation=.*$/&\nRequires=isulad.service /" "${unitfile_destdir}/k3s-agent.service"
            sed -i "s/^Requires=isulad.service/&\nAfter=isulad.service/" "${unitfile_destdir}/k3s-agent.service"
          elif [ "${container_runtime_endpoint}" = "embedded" ]; then
            install "${WORKDIR}/k3s-airgap-images-arm64.tar.gz" "${D}${localstatedir}/lib/rancher/k3s/agent/images"
          else
            # customize your endpoint setup functions in k3s_%.bbappend
            install_other_endpoint
          fi

        else
          echo "Systemd-free k3s hasn't implemented!"
          install -d "${D}${sysconfdir}/init.d"
          install -d "${D}${sysconfdir}/rcS.d"
          exit -1
        fi
}



install_other_endpoint() {
    bbwarn " \
    Using ${container_runtime_endpoint} as the container runtime endpoint \
    You should overwrite install_more_endpoint function in k3s_%.bbappend \
  to customize your endpoint setup functions \
  "
}

compress_binaries() {
    bbplain "compressing binaries"
}

FULL_K3S_FILES = "\
    ${k3s_bindir}/crictl \
    ${k3s_bindir}/kubectl \
    ${k3s_bindir}/ctr \
    ${k3s_bindir}/k3s-secrets-encrypt \
    ${k3s_bindir}/k3s-certificate \
    ${k3s_bindir}/k3s-server \
    ${k3s_bindir}/k3s-killall.sh \
    ${unitfile_destdir}/k3s.service \
"

FILES:${PN} += "\
    ${k3s_bindir}/k3s-install-agent \
    ${k3s_bindir}/k3s-kill-agent \
    ${unitfile_destdir}/k3s-agent.service \
    ${bb.utils.contains('full_k3s', 'true', '${FULL_K3S_FILES}', '', d)} \
"

#${sysconfdir}/systemd/system/k3s-agent.service,
#${bb.utils.contains('full_k3s', 'true', 'k3s.service', '', d)}  
SYSTEMD_SERVICE:k3s = " k3s-agent.service \
  k3s.service\
"

USE_PREBUILD_SHIM_V2 = "${@bb.utils.contains_any('ARCH', 'arm riscv64', '0', '1', d)}"

RDEPENDS:${PN} = "\
  conntrack-tools \
  coreutils \
  findutils \
  iproute2 \
  iptables \
  ${@bb.utils.contains('USE_PREBUILD_SHIM_V2', '1', 'lib-shim-v2-bin', 'lib-shim-v2', d)} \
"

RDEPENDS:${PN} += "\
    kernel-module-br-netfilter \
    kernel-module-bridge \
    kernel-module-iptable-mangle \
    kernel-module-ip6table-mangle \
    kernel-module-libcrc32c \
    kernel-module-nf-conntrack \
    kernel-module-nf-nat \
    kernel-module-nf-defrag-ipv4 \
    kernel-module-nf-defrag-ipv6 \
    kernel-module-stp \
    kernel-module-xt-addrtype \
    kernel-module-xt-comment \
    kernel-module-xt-nat \
    kernel-module-xt-tcpudp \
"

RRECOMMENDS:${PN} = "\
    kernel-module-nf-conntrack-netlink \
    kernel-module-nfnetlink-log \
    kernel-module-nfnetlink  \
    kernel-module-nft-chain-nat \
    kernel-module-nft-compat \
    kernel-module-nft-counter \
    kernel-module-xt-addrtype \
    kernel-module-xt-comment \
    kernel-module-xt-connmark \
    kernel-module-xt-conntrack \
    kernel-module-xt-limit \
    kernel-module-xt-mark \
    kernel-module-xt-masquerade \
    kernel-module-xt-multiport \
    kernel-module-xt-nflog \
    kernel-module-xt-physdev \
    kernel-module-xt-nat \
    kernel-module-xt-statistic \
    kernel-module-xt-conntrack \
    kernel-module-xt-statistic \
    kernel-module-xt-physdev \
    kernel-module-vxlan \
"

INHIBIT_PACKAGE_STRIP = "1"
INSANE_SKIP:${PN} += "ldflags already-stripped"
