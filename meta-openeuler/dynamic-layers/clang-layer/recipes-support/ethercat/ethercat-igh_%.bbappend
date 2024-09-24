TOOLCHAIN = "clang"

do_compile:append:toolchain-clang:x86-64() {
	# Do not rebuild ethercat in install stage
	touch tool/ethercat
}
