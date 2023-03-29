# fix segmentfault error when compiling with clang
SRC_URI:append = " \
        file://0001-apps-Fix-atomic_flag-error-for-clang-compilation.patch \
	file://0002-lib-Fix-atomic_flag-error-for-clang-compilation.patch \
"
