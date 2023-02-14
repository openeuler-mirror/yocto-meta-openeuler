# add a wrapper for users to use ${TARGET_PREFIX}-clang/clang++ 
# compiling target binary conveniently.
CLANGCC=${OECORE_NATIVE_SYSROOT}/usr/bin/${TARGET_PREFIX}clang
CLANGCXX=${OECORE_NATIVE_SYSROOT}/usr/bin/${TARGET_PREFIX}clang++
echo "#!/bin/bash\nexec ${CC} \"\$@\"" > ${CLANGCC}
echo "#!/bin/bash\nexec ${CXX} \"\$@\"" > ${CLANGCXX}
chmod +x ${CLANGCC} ${CLANGCXX}
