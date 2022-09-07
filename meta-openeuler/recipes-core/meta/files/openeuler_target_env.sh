export KERNEL_SRC_DIR="${SDKTARGETSYSROOT}/usr/src/kernel"
# prepare context for kernel module development
pushd "${SDKTARGETSYSROOT}/usr/src/kernel"
make modules_prepare
popd
