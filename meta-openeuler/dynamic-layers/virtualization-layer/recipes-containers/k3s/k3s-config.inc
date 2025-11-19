# Common k3s configuration shared between packagegroup-k3s and k3s recipe
#
# This file defines the mapping between container engines and their
# corresponding k3s versions and packagegroups.


# External container engine flag
# Set to "isulad" or "containerd" to use external container runtime.
# Set to "" (empty) to use k3s-bundled containerd (default).
# When set, k3s will be configured with --container-runtime-endpoint.
K3S_EXTERNAL_ENDPOINT ?= ""
K3S_ROLE ?= "agent"
# used for downloading dependencies during do_fetch
K3S_DEP_SRC_URI_FILE ?= ""
K3S_DEP_RELOCATION_FILE ?= ""
K3S_DEP_MODULES_TXT ?= ""

# building options:
# k3s additional abilities:
apparmor="0"
selinux="0"
# hightly recommended to statically build
static_build="1"

# Use prebuilt k3s binary from k3s.io instead of building from source
# Set to "1" to enable using prebuilt binaries (much faster)
# Remain empty to build from source (default)
K3S_PREBUILD_BINARY ?= ""
K3S_MIRROR_URL ?= ""
upx_compress = "false"
K3S_ARCH:x86-64 = "amd64"
K3S_ARCH:arm = "arm"
K3S_ARCH:aarch64 = "arm64"



python () {
    endpoint = (d.getVar('K3S_EXTERNAL_ENDPOINT') or '').strip()
    d.setVar('K3S_EXTERNAL_ENDPOINT', endpoint)
    d.setVar('K3S_EFFECTIVE_EXTERNAL_ENDPOINT', endpoint)
}


# Mapping of container engines to k3s versions and packagegroups
# These dictionaries are used by both recipes to ensure consistency
def get_k3s_variants(d):
    """Return k3s version mapping for different container engines"""
    return {
        "isulad": {
            "branch": "release-1.22",
            "pv": "v1.22.6+k3s1",
            "srcrev": "4262c6b91a43ef8411870f72ff8b8715949f90e2",
            "baisc_build_tags": "no_btrfs ctrd  netcgo osusergo providerless",
            # "pv": "v1.22.17-k3s1",
            # "srcrev": "3ed243df453edc27d20b8d5efa74eb0cbba4548b",
        },
        # version for both external containerd and bundled containerd
        "containerd": {
            "branch": "release-1.27",
            "pv": "v1.27.15-rc2+k3s1",
            "srcrev": "cb36c910a6d1b111d13a9e39b9158703bf8f3274",
            "basic_build_tags": "urfave_cli_no_docs static_build ctrd  netcgo osusergo providerless",
        },
        "bundle-containerd": {
            "branch": "release-1.27",
            "pv": "v1.27.15-rc2+k3s1",
            "srcrev": "cb36c910a6d1b111d13a9e39b9158703bf8f3274",
            "basic_build_tags": "urfave_cli_no_docs static_build ctrd  netcgo osusergo providerless",
        }
    }

# TODO: add more like cri-o, podman, ...
# key name == container engine name
def get_container_engine_pkg(d):
    ce_pkgs = {
        "isulad": "packagegroup-isulad",
        "containerd": "packagegroup-basic-containerd",
    }
    return ce_pkgs

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