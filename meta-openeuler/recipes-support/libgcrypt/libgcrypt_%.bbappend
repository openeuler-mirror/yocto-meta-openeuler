# the main bb file: yocto-poky/meta/recipes-support/libgcrypt/libgcrypt_1.9.4.bb

PV = "1.10.2"

# patches in openEuler
SRC_URI:prepend = " \
    file://${BP}.tar.bz2 \
    file://Use-the-compiler-switch-O0-for-compiling-jitterentro.patch \
    file://add-GCRY_MD_SM3_PGP-set-to-109.patch \
    "

# All patches from libgcrypt_1.10.2.bb are for 1.10.x code and do not apply
# to the OpenEuler 1.12.2 source tarball
SRC_URI:remove = "file://0001-libgcrypt-fix-m4-file-for-oe-core.patch \
    file://0002-libgcrypt-fix-building-error-with-O2-in-sysroot-path.patch \
    file://0004-tests-Makefile.am-fix-undefined-reference-to-pthread.patch \
    file://no-native-gpg-error.patch \
    file://no-bench-slope.patch \
    "

ASSUME_PROVIDE_PKGS = "libgcrypt"

# libgpg-error 1.47+ ships a gpg-error-config wrapper that always exits 1 and
# says "use pkg-config instead".  libgcrypt's configure uses gpg-error-config to
# detect libgpg-error version/flags.  Create a working wrapper that delegates to
# pkg-config so configure can complete successfully.
do_configure:prepend () {
    cat > ${WORKDIR}/gpg-error-config-wrapper << 'EOF'
#!/bin/sh
case "$1" in
    --version) exec pkg-config --modversion gpg-error ;;
    --cflags)  exec pkg-config --cflags gpg-error ;;
    --libs)    exec pkg-config --libs gpg-error ;;
    --mt)      shift; exec pkg-config "$@" gpg-error ;;
    *)         exec pkg-config --exists gpg-error ;;
esac
EOF
    chmod +x ${WORKDIR}/gpg-error-config-wrapper
    export GPG_ERROR_CONFIG="${WORKDIR}/gpg-error-config-wrapper"
}
