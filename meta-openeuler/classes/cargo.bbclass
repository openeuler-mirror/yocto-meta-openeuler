# This file is developed based on meta-rust-bin(https://github.com/rust-embedded/meta-rust-bin) 
# using MIT License
# 
# Copyright © 2016 meta-rust-bin author
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
# and associated documentation files (the “Software”), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, 
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or 
# substantial portions of the Software.

RUST_BASE_URI := "https://static.rust-lang.org"

# Many crates rely on pkg-config to find native versions of their libraries for
# linking - do the simple thing and make it generally available.
DEPENDS:append = "\
    cargo-bin-cross-${TARGET_ARCH} \
    pkgconfig-native \
"

# Move CARGO_HOME from default of ~/.cargo
export CARGO_HOME = "${WORKDIR}/cargo_home"

# If something fails while building, this might give useful information
export RUST_BACKTRACE = "1"

# Do build out-of-tree
B = "${WORKDIR}/target"
export CARGO_TARGET_DIR = "${B}"

RUST_TARGET = "${@rust_target(d, 'TARGET')}"
RUST_BUILD = "${@rust_target(d, 'BUILD')}"

# Additional flags passed directly to the "cargo build" invocation
EXTRA_CARGO_FLAGS ??= ""
EXTRA_RUSTFLAGS ??= ""
RUSTFLAGS += "${EXTRA_RUSTFLAGS}"

# Space-separated list of features to enable
CARGO_FEATURES ??= ""

# Control the Cargo build type (debug or release)
CARGO_BUILD_TYPE ?= "--release"

CARGO_INSTALL_DIR ?= "${D}${bindir}"

CARGO_DEBUG_DIR = "${B}/${RUST_TARGET}/debug"
CARGO_RELEASE_DIR = "${B}/${RUST_TARGET}/release"
WRAPPER_DIR = "${WORKDIR}/wrappers"

# Set the Cargo manifest path to the typical location
CARGO_MANIFEST_PATH ?= "${S}/Cargo.toml"

FILES:${PN}-dev += "${libdir}/*.rlib"
FILES:${PN}-dev += "${libdir}/*.rlib.*"

CARGO_BUILD_FLAGS = "\
    --verbose \
    --manifest-path ${CARGO_MANIFEST_PATH} \
    --target=${RUST_TARGET} \
    ${CARGO_BUILD_TYPE} \
    ${@oe.utils.conditional('CARGO_FEATURES', '', '', '--features "${CARGO_FEATURES}"', d)} \
    ${EXTRA_CARGO_FLAGS} \
"

# CARGO_CRATES_SOURCE setting can enable replacement of crates source
# simply, you can set CARGO_CRATES_SOURCE = "tuna"
CARGO_CRATES_SOURCE ??= ""

write_cargo_source() {
    varname="$1"
    varval="$2"
    if [ "${varval}" != "None" ]; then
        cat <<- EOF >> ${CARGO_HOME}/config
${varname} = "${varval}"
EOF
    fi
}

create_cargo_config() {
    if [ "${RUST_BUILD}" != "${RUST_TARGET}" ]; then
        cat <<- EOF > ${CARGO_HOME}/config
[target.${RUST_BUILD}]
linker = '${WRAPPER_DIR}/ld-native-wrapper.sh'

[target.${RUST_TARGET}]
linker = '${WRAPPER_DIR}/ld-wrapper.sh'

EOF
    else
        cat <<- EOF > ${CARGO_HOME}/config
[target.${RUST_TARGET}]
linker = '${WRAPPER_DIR}/ld-wrapper.sh'

EOF
    fi

    cat <<- EOF >> ${CARGO_HOME}/config
[build]
rustflags = ['-C', 'rpath']

[profile.release]
debug = true

EOF

    if [ -n "${CARGO_CRATES_SOURCE}" ]; then
        cat <<- EOF >> ${CARGO_HOME}/config
[source.crates-io]
replace-with = "${CARGO_CRATES_SOURCE}"

[source.${CARGO_CRATES_SOURCE}]

EOF

    write_cargo_source "registry" "${@d.getVarFlag('CARGO_CRATES_SOURCE', 'registry', True)}"
    write_cargo_source "local-registry" "${@d.getVarFlag('CARGO_CRATES_SOURCE', 'local-registry', True)}"
    write_cargo_source "directory" "${@d.getVarFlag('CARGO_CRATES_SOURCE', 'directory', True)}"
    write_cargo_source "git" "${@d.getVarFlag('CARGO_CRATES_SOURCE', 'git', True)}"
    write_cargo_source "branch" "${@d.getVarFlag('CARGO_CRATES_SOURCE', 'branch', True)}"
    write_cargo_source "tag" "${@d.getVarFlag('CARGO_CRATES_SOURCE', 'tag', True)}"
    write_cargo_source "rev" "${@d.getVarFlag('CARGO_CRATES_SOURCE', 'rev', True)}"
    fi
}

cargo_do_configure() {
    mkdir -p "${B}"
    mkdir -p "${CARGO_HOME}"
    mkdir -p "${WRAPPER_DIR}"

    # Yocto provides the C compiler in ${CC} but that includes options beyond
    # the compiler binary. cargo/rustc expect a single binary, so we put ${CC}
    # in a wrapper script.
    cat <<- EOF > "${WRAPPER_DIR}/cc-wrapper.sh"
#!/bin/sh
${CC} "\$@"
EOF
    chmod +x "${WRAPPER_DIR}/cc-wrapper.sh"

    cat <<- EOF > "${WRAPPER_DIR}/cxx-wrapper.sh"
#!/bin/sh
${CXX} "\$@"
EOF
    chmod +x "${WRAPPER_DIR}/cxx-wrapper.sh"

    cat <<- EOF > "${WRAPPER_DIR}/cc-native-wrapper.sh"
#!/bin/sh
${BUILD_CC} "\$@"
EOF
    chmod +x "${WRAPPER_DIR}/cc-native-wrapper.sh"

    cat <<- EOF > "${WRAPPER_DIR}/cxx-native-wrapper.sh"
#!/bin/sh
${BUILD_CXX} "\$@"
EOF
    chmod +x "${WRAPPER_DIR}/cxx-native-wrapper.sh"

    cat <<- EOF > "${WRAPPER_DIR}/ld-wrapper.sh"
#!/bin/sh
${CC} ${LDFLAGS} "\$@"
EOF
    chmod +x "${WRAPPER_DIR}/ld-wrapper.sh"

    cat <<- EOF > "${WRAPPER_DIR}/ld-native-wrapper.sh"
#!/bin/sh
${BUILD_CC} ${BUILD_LDFLAGS} "\$@"
EOF
    chmod +x "${WRAPPER_DIR}/ld-native-wrapper.sh"

    # Create our global config in CARGO_HOME
    create_cargo_config
}

cargo_do_compile() {
    export TARGET_CC="${WRAPPER_DIR}/cc-wrapper.sh"
    export TARGET_CXX="${WRAPPER_DIR}/cxx-wrapper.sh"
    export CC="${WRAPPER_DIR}/cc-native-wrapper.sh"
    export CXX="${WRAPPER_DIR}/cxx-native-wrapper.sh"
    export TARGET_LD="${WRAPPER_DIR}/ld-wrapper.sh"
    export LD="${WRAPPER_DIR}/ld-native-wrapper.sh"
    export PKG_CONFIG_ALLOW_CROSS="1"
    export LDFLAGS=""
    export RUSTFLAGS="${RUSTFLAGS}"
    bbdebug 2 "which rustc:" `which rustc`
    bbdebug 2 "rustc --version" `rustc --version`
    bbdebug 2 "which cargo:" `which cargo`
    bbdebug 2 "cargo --version" `cargo --version`
    bbdebug 2 cargo build ${CARGO_BUILD_FLAGS}
    cargo build ${CARGO_BUILD_FLAGS}
}

cargo_do_install() {
    if [ "${CARGO_BUILD_TYPE}" = "--release" ]; then
        local cargo_bindir="${CARGO_RELEASE_DIR}"
    else
        local cargo_bindir="${CARGO_DEBUG_DIR}"
    fi

    local files_installed=""

    for tgt in "${cargo_bindir}"/*; do
        case $tgt in
            *.so|*.rlib)
                so_name=$(basename $tgt)
                install -d "${D}${libdir}"
                install -m755 "$tgt" "${D}${libdir}/$so_name.${PV}"
                cd "${D}${libdir}" && ln -fs "$so_name" "$so_name.${PV}"
                files_installed="$files_installed $tgt"
                ;;
            *examples)
                if [ -d "$tgt" ]; then
                    for example in "$tgt/"*; do
                        if [ -f "$example" ] && [ -x "$example" ]; then
                            install -d "${CARGO_INSTALL_DIR}"
                            install -m755 "$example" "${CARGO_INSTALL_DIR}"
                            files_installed="$files_installed $example"
                        fi
                    done
                fi
                ;;
            *)
                if [ -f "$tgt" ] && [ -x "$tgt" ]; then
                    install -d "${CARGO_INSTALL_DIR}"
                    install -m755 "$tgt" "${CARGO_INSTALL_DIR}"
                    files_installed="$files_installed $tgt"
                fi
                ;;
        esac
    done

    if [ -z "$files_installed" ]; then
        bbfatal "Cargo found no files to install"
    else
        bbnote "Installed the following files:"
        for f in $files_installed; do
            bbnote "  " `basename $f`
        done
    fi
}

def rust_target(d, spec_type):
    '''
    Convert BitBake system specs into Rust target.
    `spec_type` is one of BUILD, TARGET, or HOST
    '''
    import re
    spec_type = spec_type.upper()

    arch = d.getVar('%s_ARCH' % spec_type, True)
    os = d.getVar('%s_OS' % spec_type, True)

    # Make sure that tasks properly recalculate after ARCH or OS change
    d.appendVarFlag("rust_target", "vardeps", " %s_ARCH" % spec_type)
    d.appendVarFlag("rust_target", "vardeps", " %s_OS" % spec_type)

    # os should in "linux" "freebsd" ...
    if '-' in os:
        os = os[:os.find('-')]

    # The bitbake vendor won't ever match the Rust specs
    vendor = "unknown"

    tclibc = d.getVar("TCLIBC", True)
    callconvention = "gnu"
    # Only install the musl target toolchain for rust
    # versions 1.35.0 and above
    if spec_type == "TARGET" and tclibc == "musl":
        pnre = re.compile("rustc-bin-cross")
        m = pnre.match(d.getVar("PN", True))
        if m:
            pv = d.getVar("PV", True)
            if pv >= "1.35.0":
                callconvention = "musl"
        else:
            callconvention = "musl"

    # TUNE_FEATURES are always only for the TARGET
    if spec_type == "TARGET":
        tune = d.getVar("TUNE_FEATURES", True).split()
        tune += d.getVar("MACHINEOVERRIDES", True).split(":")
    else:
        tune = []

    if arch in ["x86_64", "x86-64", "x64", "amd64"]:
        arch = "x86_64"
    elif arch in ["arm", "armv6l", "armv7l"]:
        # Rust requires NEON/VFP in order to build for armv7, else fall back to v6
        tune_armv7 = any(t.startswith("armv7") for t in tune)
        tune_neon = "neon" in tune
        tune_cchard = "callconvention-hard" in tune
        if all([tune_armv7, tune_neon, tune_cchard]):
            arch = "armv7"
            callconvention += "eabihf"
        elif any(t.startswith("armv5") for t in tune):
            arch = "armv5te"
            callconvention += "eabi"
        else:
            arch = "arm"
            if tune_cchard:
                callconvention += "eabihf"
            else:
                callconvention += "eabi"
    elif arch in ["aarch64"]:
        arch = "aarch64"
    else:
        bb.fatal("Unknown or unsupported architecture: %s" % arch)

    target = "%s-%s-%s-%s" % (arch, vendor, os, callconvention)

    return target

rust_target[vardepsexclude] += "rust_target[vardeps]"

EXPORT_FUNCTIONS do_configure do_compile do_install

# skip riscv as they are not well supported by rust now
COMPATIBLE_HOST:riscv64 = "null"
COMPATIBLE_HOST:riscv32 = "null"
