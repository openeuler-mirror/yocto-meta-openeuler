do_install:append() {
    # for clang and ld.lld to compile kernel, need to add CC="prefix-clang" and LD="prefix-ld.lld" before make
    sed -i 's/make modules_prepare/make CC=\"$CC\" LD=\"$LD\" modules_prepare/g' ${openeuler_env_path}/openeuler_target_env.sh
}
