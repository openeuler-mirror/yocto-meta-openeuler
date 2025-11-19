FILESEXTRAPATHS:prepend := "${THISDIR}:"
CNI_NETWORKING_FILES ?= "${WORKDIR}/cni-containerd-net.conf"
SRCREV_FORMAT = "k3s"

SRC_URI = ""

require k3s-config.inc

python () {
    variants = get_k3s_variants(d)

    external_endpoint = (d.getVar('K3S_EXTERNAL_ENDPOINT') or '').strip()

    if external_endpoint:
        selected_engine = external_endpoint
        bb.note("K3S: External container engine is %s, selecting %s version" % (selected_engine, selected_engine))
    else: # fallback/default to bundle-containerd
        selected_engine = "bundle-containerd"

    if selected_engine not in variants:
        bb.warn('Unknown selected container engine "%s", falling back to containerd' % selected_engine)
        selected_engine = "containerd"

    variant = variants[selected_engine]
    pv = variant['pv']
    srcrev = variant['srcrev']
    d.setVar('K3S_BRANCH', variant['branch'])
    d.setVar('PV', variant['pv'] + "+git" + variant['srcrev'])
    d.setVar('SRCREV_k3s', variant['srcrev'])
    d.setVar('K3S_SELECTED_ENGINE', selected_engine)

    # Select dependency files based on container engine and binary source
    # When using prebuilt binary, these files are not needed (skip them)
    d.setVar('K3S_DEP_SRC_URI_FILE', 'src_uri-' + pv + '.inc')
    d.setVar('K3S_DEP_RELOCATION_FILE', 'relocation-' + pv + '.inc')
    d.setVar('K3S_DEP_MODULES_TXT', 'modules-' + pv + '.txt')
    d.setVar('K3S_BUILD_TAGS', variant.get('basic_build_tags', ''))
    if selected_engine == "bundle-containerd":
        bb.note("K3S: Using prebuilt binary, skipping dependency source/relocation files")
        d.setVar('K3S_DEP_SRC_URI_FILE', '')
        d.setVar('K3S_DEP_RELOCATION_FILE', '')
        d.setVar('K3S_DEP_MODULES_TXT', '')
}


K3S_BUILD_TAGS:append = "\
    ${@bb.utils.contains('apparmor', '1', 'apparmor', '', d)} \
    ${@bb.utils.contains('selinux', '1', 'selinux', '', d)} \
    ${@bb.utils.contains('static_build', '1', ' static_build libsqlite3', '', d)} \
"

require ${K3S_DEP_SRC_URI_FILE}
require ${K3S_DEP_RELOCATION_FILE}
SRC_URI_MODULES = "\
    ${@'file://${K3S_DEP_MODULES_TXT}' if d.getVar('K3S_DEP_MODULES_TXT') else ''} \
"

SRC_URI += " \
    git://github.com/k3s-io/k3s.git;branch=${K3S_BRANCH};name=k3s;protocol=https \
    file://k3s.service \
    file://k3s-agent.service \
    file://k3s-install-agent \
    file://k3s-clean \
    file://cni-containerd-net.conf \
    file://0001-Finding-host-local-in-usr-libexec.patch;patchdir=src/import \
    file://k3s-killall.sh \
    ${SRC_URI_MODULES} \
"

BIN_PREFIX = "${exec_prefix}"
GO_EXTRA_LDFLAGS += " \
    ${@bb.utils.contains('static_build', '1', '-static', '', d)} \
    -lm -ldl -lz -lpthread \
"
GO_BUILD_LDFLAGS = "-X github.com/k3s-io/k3s/pkg/version.Version=${PV} \
                    -X github.com/k3s-io/k3s/pkg/version.GitCommit=${@d.getVar('SRCREV_k3s', d, 1)[:8]} \
                    -w -s \
                    -extldflags '${GO_EXTRA_LDFLAGS}' \
                   "

K3S_AGENT_BUILD_TAGS ?= "${K3S_BUILD_TAGS}"


do_download_prebuilt() {
    if [ "${K3S_PREBUILD_BINARY}" != "1" ]; then
        return 0
    fi

    install -d "${S}/src/import/dist/artifacts"
    cd "${S}/src/import/dist/artifacts"

    K3S_BINARY_NAME="k3s"
    if [ "${K3S_ARCH}" != "amd64" ]; then
        K3S_BINARY_NAME="k3s-${K3S_ARCH}"
    fi

    K3S_DOWNLOAD_URL="${K3S_MIRROR_URL:-https://github.com/k3s-io/k3s/releases/download/${PV}}"

    bbnote "Downloading k3s prebuilt binary from ${K3S_DOWNLOAD_URL}/${K3S_BINARY_NAME}"

    if command -v curl > /dev/null 2>&1; then
        curl -sfL "${K3S_DOWNLOAD_URL}/${K3S_BINARY_NAME}" -o k3s
    elif command -v wget > /dev/null 2>&1; then
        wget -qO k3s "${K3S_DOWNLOAD_URL}/${K3S_BINARY_NAME}"
    else
        bberror "Neither curl nor wget is available for downloading k3s binary"
        return 1
    fi

    if [ ! -f k3s ]; then
        bberror "k3s binary download failed"
        return 1
    fi

    chmod +x k3s
    bbnote "Successfully downloaded k3s binary"

    if ! ./k3s --version > /dev/null 2>&1; then
        bberror "Downloaded k3s binary is not valid or not executable"
        return 1
    fi

}

do_download_prebuilt[network] = "1"
addtask download_prebuilt before do_compile after do_fetch

inherit go-mod

DEPENDS += "${@bb.utils.contains('static_build', '1', 'zlib-native zlib', 'zlib', d)}"

do_compile[network] = "1"
# do_compile[cleandirs] += "${B}/bin ${B}/.mod"

k3s_fix_gomodcache_perms() {
    if [ -d "${B}/.mod" ]; then
        chmod -R u+rwX,go+rwX "${B}/.mod" || bbfatal "Failed to fix permissions for ${B}/.mod"
    fi
    bbnote "set current gomocache dir: ${GOMODCACHE} permissions are: $(stat -c %a ${GOMODCACHE})"
}

do_compile[postfuncs] += " k3s_fix_gomodcache_perms"
do_compile[prefuncs] += " k3s_fix_gomodcache_perms "
# Wanna fetch k3s dependencies dureing do_fetch(), just rewrite do_compile():
# * we have prepared src_uri-${PV}.inc, relocation-${PV}.inc and modules-${PV}.txt files,
#   hence you can keep do_fetch unchanged
# * do_compile[network] = "0"
# * comment do_compile[postfuncs] += " k3s_fix_gomodcache_perms"
# * comment do_compile[prefuncs] += " k3s_fix_gomodcache_perms"
# * mapping dependencies cache to correct location, according to the guide [yocto-meta-openeuler/scripts/oe-go-mod-autogen.py]
#   or read [meta-virtualization/recipes-containers/k3s/k3s_git.bb as reference]
# * change build mode to go vendor 
do_compile() {
    if [ "${K3S_PREBUILD_BINARY}" = "1" ]; then
        if [ -f "${S}/src/import/dist/artifacts/k3s" ]; then
            bbnote "Skipping compilation, using prebuilt k3s binary"
            return 0
        else
            bberror "K3S_PREBUILD_BINARY is set but binary not found at ${S}/src/import/dist/artifacts/k3s"
            return 1
        fi
    fi

    export GOPATH=${S}
    export GO111MODULE=on
    export GOMODCACHE="${B}/.mod"
    export CGO_ENABLED="1"
    export GOPROXY="https://goproxy.cn,https://goproxy.io,https://mirrors.aliyun.com/goproxy/,direct"
    export GOARCH=${TARGET_ARCH}
    export GIT_SSL_NO_VERIFY=1
    git config --global http.sslVerify false
    bbnote "GOPRIVATE=${GOPRIVATE},GOSUMDB=${GOSUMDB}"
    cd ${S}/src/import

    build_target="./cmd/server/main.go"
    build_output="./dist/artifacts/k3s"
    build_tags="${K3S_BUILD_TAGS}"
    if [ "${K3S_ROLE}" = "agent" ]; then
        build_target="./cmd/agent/main.go"
        build_tags="${K3S_AGENT_BUILD_TAGS}"
    fi

    bbnote "GO_BUILD_TAGS=${K3S_BUILD_TAGS}"
    bbnote "GO_LD_FLAGS=${GO_BUILD_LDFLAGS}"

    ${GO} build -tags "${build_tags}" -ldflags "${GO_BUILD_LDFLAGS} " -o ${build_output} ${build_target}

    bbnote "Successfully built k3s version ${PV}"
}


do_compile:append() {
    if [ "${upx_compress}" = "true" ] && command -v upx > /dev/null; then
        upx -9 ${build_output}
    fi
}

do_install() {
    install -d "${D}${BIN_PREFIX}/bin"
    install -d "${D}/etc/rancher/k3s"
    k3s_bin="${S}/src/import/dist/artifacts/k3s"

    install -m 0755 "${k3s_bin}" "${D}${BIN_PREFIX}/bin/k3s"
    ln -sr "${D}${BIN_PREFIX}/bin/k3s" "${D}${BIN_PREFIX}/bin/kubectl"
    ln -sr "${D}${BIN_PREFIX}/bin/k3s" "${D}${BIN_PREFIX}/bin/crictl"
    if [ "${K3S_EXTERNAL_ENDPOINT}" != "containerd" ]; then
        ln -sr "${D}${BIN_PREFIX}/bin/k3s" "${D}${BIN_PREFIX}/bin/ctr"
    else
        bbnote "use containerd as container engine, k3s multi-call ctr links are skipped"
    fi

    install -m 0755 "${WORKDIR}/k3s-clean" "${D}${BIN_PREFIX}/bin"
    install -m 0755 "${WORKDIR}/k3s-killall.sh" "${D}${BIN_PREFIX}/bin"
    install -m 0755 "${WORKDIR}/k3s-install-agent" "${D}${BIN_PREFIX}/bin/k3s-agent"

    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        # install to k3s-service packages 
        install -D -m 0644 "${WORKDIR}/k3s.service" "${D}${systemd_system_unitdir}/k3s.service"
        sed -i "s#/usr/local#${BIN_PREFIX}#g" "${D}${systemd_system_unitdir}/k3s.service"
        cp "${D}${systemd_system_unitdir}/k3s.service" "${D}${systemd_system_unitdir}/k3s.service.ori"
        
        install -D -m 0644 "${WORKDIR}/k3s-agent.service" "${D}${systemd_system_unitdir}/k3s-agent.service"
        sed -i "s#/usr/local#${BIN_PREFIX}#g" "${D}${systemd_system_unitdir}/k3s-agent.service"
        cp "${D}${systemd_system_unitdir}/k3s-agent.service" "${D}${systemd_system_unitdir}/k3s-agent.service.ori"

        if [ "${K3S_SELECTED_ENGINE}" = "bundle-containerd" ]; then
            sed -i 's/@default_container_engine@//g' "${D}${BIN_PREFIX}/bin/k3s-agent"
        else
            sed -i "s/@default_container_engine@/${K3S_SELECTED_ENGINE}/g" "${D}${BIN_PREFIX}/bin/k3s-agent"
        fi

        if [ -n "${K3S_EXTERNAL_ENDPOINT}" ]; then
            if [ "${K3S_EXTERNAL_ENDPOINT}" = "isulad" ]; then
                SERVICE_NAME="isulad.service"
                RUNTIME_ENDPOINT="unix:///var/run/isulad.sock"
            elif [ "${K3S_EXTERNAL_ENDPOINT}" = "containerd" ]; then
                SERVICE_NAME="containerd.service"
                RUNTIME_ENDPOINT="unix:///run/containerd/containerd.sock"
            fi
            # no need to configure service for k3s.service 'cause k3s server should configure a lot
            if [ -n "${SERVICE_NAME}" ]; then
                bbnote "Configuring k3s agent to use external container runtime: ${K3S_EXTERNAL_ENDPOINT}"
                if ! grep -q "^Requires=" "${D}${systemd_system_unitdir}/k3s-agent.service"; then
                    sed -i "/^\[Unit\]/a Requires=${SERVICE_NAME}" \
                        "${D}${systemd_system_unitdir}/k3s-agent.service"
                else
                    sed -i "s|^Requires=.*|Requires=${SERVICE_NAME}|" \
                        "${D}${systemd_system_unitdir}/k3s-agent.service"
                fi
                if ! grep -q "^After=" "${D}${systemd_system_unitdir}/k3s-agent.service"; then
                    sed -i "/^\[Unit\]/a After=${SERVICE_NAME}" \
                        "${D}${systemd_system_unitdir}/k3s-agent.service"
                else
                    sed -i "s|^After=.*|After=network-online.target ${SERVICE_NAME}|" \
                        "${D}${systemd_system_unitdir}/k3s-agent.service"
                fi
                sed -i "s|^ExecStart=.*k3s agent|ExecStart=${BIN_PREFIX}/bin/k3s agent --container-runtime-endpoint=${RUNTIME_ENDPOINT}|" \
                    "${D}${systemd_system_unitdir}/k3s-agent.service"
            fi
        fi
    else
        bbwarn "systemd is highly recommended for k3s"
    fi
}

FILES:${PN}-server += "${systemd_system_unitdir}/k3s.service.ori"
FILES:${PN}-agent += "${systemd_system_unitdir}/k3s-agent.service.ori"

# external container engine selection
python () {
    engine_pkgs = get_container_engine_pkg(d)
    endpoint = d.getVar('K3S')
    d.setVar('engine_pkg', engine_pkgs.get('K3S_SELECTED_ENGINE', ''))
}

RDEPENDS:${PN} += " \
    ${@bb.utils.contains('K3S_SELECTED_ENGINE','bundle-containerd','','${engine_pkg}',d)} \
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

RRECOMMENDS:${PN} += " \
    kernel-module-nf-conntrack-netlink \
    kernel-module-nfnetlink \
    kernel-module-nfnetlink-log \
    kernel-module-nft-chain-nat \
    kernel-module-nft-compat \
    kernel-module-nft-counter \
    kernel-module-xt-connmark \
    kernel-module-xt-conntrack \
    kernel-module-xt-limit \
    kernel-module-xt-mark \
    kernel-module-xt-masquerade \
    kernel-module-xt-multiport \
    kernel-module-xt-nflog \
    kernel-module-xt-physdev \
    kernel-module-xt-statistic \
    kernel-module-vxlan \
    kernel-module-ip-vs \
    kernel-module-ip-vs-rr \
    kernel-module-ip-vs-sh \
    kernel-module-ip-vs-wrr \
"
