# Build python3-cryptography-native from the upstream prebuilt manylinux
# wheel instead of compiling the Rust backend from source.
#
# Rationale: the source build pulls the whole
# cargo-native -> rust-native -> rust-llvm-native toolchain, which costs
# hours of compilation plus slow fetches from static.rust-lang.org and
# crates.io. The consumers in this workspace (optee-os-stm32mp,
# m33projects, tf-m, optee examples/tests) only run cryptography on the
# build host for TA / firmware signing scripts, so the abi3 manylinux
# wheel - which bundles the precompiled Rust backend and a statically
# linked OpenSSL - is functionally equivalent on the x86_64 build host.
#
# The target and nativesdk variants are untouched and still build from
# source.
#
# NOTE: this file must live directly under recipes-devtools/python/ (not
# in a python3-cryptography/ subdirectory) because this layer's BBFILES
# pattern "recipes-*/*/*.bbappend" only matches two directory levels.

CRYPTOGRAPHY_NATIVE_WHL = "cryptography-39.0.2-cp36-abi3-manylinux_2_28_x86_64.whl"

SRC_URI:append:class-native = " \
    https://pypi.tuna.tsinghua.edu.cn/packages/f4/6d/1afb19efbe093f0b1af7a788bb8a693e495dc6c1d2139316b05b40f5e1dd/${CRYPTOGRAPHY_NATIVE_WHL};subdir=native-wheel;name=whl;downloadfilename=${CRYPTOGRAPHY_NATIVE_WHL} \
"
SRC_URI[whl.sha256sum] = "b49a88ff802e1993b7f749b1eeb31134f03c8d5c956e3c125c75558955cda536"

# Cut every Rust-toolchain dependency path for the native variant:
# - python_setuptools3_rust adds python3-setuptools-rust-native
# - python_setuptools3_rust inherits python_pyo3, which inherits cargo;
#   cargo.bbclass appends cargo-native to BASEDEPENDS and rust-native to
#   DEPENDS for the native class
# - crate:// entries feed the Rust source build only
BASEDEPENDS:remove:class-native = "cargo-native"
DEPENDS:remove:class-native = "python3-setuptools-rust-native rust-native"

python () {
    if d.getVar("CLASSOVERRIDE") == "class-native":
        uris = d.getVar("SRC_URI").split()
        d.setVar("SRC_URI", " ".join(u for u in uris if not u.startswith("crate://")))
}

do_compile:class-native = ""

do_install:class-native() {
    install -d ${D}${PYTHON_SITEPACKAGES_DIR}
    unzip -q ${WORKDIR}/native-wheel/${CRYPTOGRAPHY_NATIVE_WHL} -d ${D}${PYTHON_SITEPACKAGES_DIR}
}
