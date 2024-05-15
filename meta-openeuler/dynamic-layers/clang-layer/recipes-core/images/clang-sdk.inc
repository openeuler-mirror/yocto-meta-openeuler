TOOLCHAIN_HOST_TASK =+ " \
clang-external-cross-canadian-${TRANSLATED_TARGET_ARCH} \
"

# no need this for clang sdk init
TOOLCHAIN_TARGET_TASK:remove = " sdk-env-external-toolchain"

# when using `clang --target=${TARGET_PREFIX}` to compile
# clang will find lib{64}/gcc/${TARGET_PREFIX}/version/crt*.o by default.
# but our sdk just has lib{64}/gcc/${TARGET_PREFIX}-gnu/version/crt*.o, which will lead compile error.
# so add a link fix this
add_target_link () {
    cd ${SDK_OUTPUT}/${SDKPATHNATIVE}/usr/lib64/gcc/
    ln -s ${EXTERNAL_TARGET_SYS} ${TARGET_SYS}
    cd -
}
SDK_POSTPROCESS_COMMAND =+ " add_target_link;"
