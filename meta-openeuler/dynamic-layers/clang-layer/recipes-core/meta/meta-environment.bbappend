# change CC/CXX/CPP/AS, etc environment variables to using clang
export TARGET_CLANGCC_ARCH = "${TARGET_CC_ARCH}"
TARGET_CLANGCC_ARCH:append = " -Wno-int-conversion "

toolchain_shared_env_script:prepend() {
        # for kernel, add `-fintegrated-as` option
        echo 'export LLVM_IAS="1"' >> $script
}

create_sdk_files:append() {
        sed -i 's/^export CC=.*/export CC=\"${TARGET_PREFIX}clang ${TARGET_CLANGCC_ARCH} --sysroot=$SDKTARGETSYSROOT\"/g' $script
        sed -i 's/^export CXX=.*/export CXX=\"${TARGET_PREFIX}clang++ ${TARGET_CLANGCC_ARCH} --sysroot=$SDKTARGETSYSROOT\"/g' $script
        sed -i 's/^export CPP=.*/export CPP=\"${TARGET_PREFIX}clang -E ${TARGET_CLANGCC_ARCH} --sysroot=$SDKTARGETSYSROOT\"/g' $script
        sed -i 's/^export LD=.*/export LD=\"${TARGET_PREFIX}ld.lld ${TARGET_LD_ARCH} --sysroot=$SDKTARGETSYSROOT\"/g' $script
        sed -i 's/^export AS=.*/export AS=\"${TARGET_PREFIX}llvm-as ${TARGET_AS_ARCH}\"/g' $script
        sed -i 's/^export STRIP=.*/export STRIP=\"${TARGET_PREFIX}llvm-strip ${TARGET_AS_ARCH}\"/g' $script
        sed -i 's/^export RANLIB=.*/export RANLIB=\"${TARGET_PREFIX}llvm-ranlib\"/g' $script
        sed -i 's/^export OBJCOPY=.*/export OBJCOPY=\"${TARGET_PREFIX}llvm-objcopy\"/g' $script
        sed -i 's/^export OBJDUMP=.*/export OBJDUMP=\"${TARGET_PREFIX}llvm-objdump\"/g' $script
        sed -i 's/^export READELF=.*/export READELF=\"${TARGET_PREFIX}llvm-readelf\"/g' $script
        sed -i 's/^export AR=.*/export AR=\"${TARGET_PREFIX}llvm-ar\"/g' $script
        sed -i 's/^export NM=.*/export NM=\"${TARGET_PREFIX}llvm-nm\"/g' $script
}
