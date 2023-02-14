# change CC/CXX/CPP environment variables to using clang
export TARGET_CLANGCC_ARCH = "${TARGET_CC_ARCH}"
TARGET_CLANGCC_ARCH:append = " -Wno-int-conversion "
create_sdk_files:append() {
        sed -i "s/^export CC=.*/export CC=\"clang --target=${TARGET_SYS} ${TARGET_CLANGCC_ARCH} --sysroot=\$SDKTARGETSYSROOT\"/g" ${script}
        sed -i "s/^export CXX=.*/export CXX=\"clang++ --target=${TARGET_SYS} ${TARGET_CLANGCC_ARCH} --sysroot=\$SDKTARGETSYSROOT\"/g" ${script}
        sed -i "s/^export CPP=.*/export CPP=\"clang -E --target=${TARGET_SYS} ${TARGET_CLANGCC_ARCH} --sysroot=\$SDKTARGETSYSROOT\"/g" ${script}
}
