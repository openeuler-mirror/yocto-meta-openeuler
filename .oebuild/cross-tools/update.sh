#!/bin/bash

function update_feature() {
	# Change GLIBC_DYNAMIC_LINKER to use lib64/xxx.ld for arm64 and lib64/lp64d/xxx.ld for riscv64
	sed -i "s#^\#define GLIBC_DYNAMIC_LINKER.*#\#undef STANDARD_STARTFILE_PREFIX_2\n\#define STANDARD_STARTFILE_PREFIX_2 \"/usr/lib64/\"\n\#define GLIBC_DYNAMIC_LINKER \"/lib%{mabi=lp64:64}%{mabi=ilp32:ilp32}/ld-linux-aarch64%{mbig-endian:_be}%{mabi=ilp32:_ilp32}.so.1\"#g" $LIB_PATH/$GCC/$GCC_DIR/gcc/config/aarch64/aarch64-linux.h
	sed -i "s#^\#define GLIBC_DYNAMIC_LINKER.*#\#define GLIBC_DYNAMIC_LINKER \"/lib64/lp64d/ld-linux-riscv\" XLEN_SPEC \"-\" ABI_SPEC \".so.1\"#g" $LIB_PATH/$GCC/$GCC_DIR/gcc/config/riscv/linux.h
	sed -i "s#^\#define MUSL_DYNAMIC_LINKER.*#\#define MUSL_DYNAMIC_LINKER \"/lib%{mabi=lp64:64}%{mabi=ilp32:ilp32}/ld-musl-aarch64%{mbig-endian:_be}%{mabi=ilp32:_ilp32}.so.1\"#g" $LIB_PATH/$GCC/$GCC_DIR/gcc/config/aarch64/aarch64-linux.h
	sed -i "s#^\#define MUSL_DYNAMIC_LINKER.*#\#define MUSL_DYNAMIC_LINKER \"/lib64/lp64d/ld-musl-riscv\" XLEN_SPEC MUSL_ABI_SUFFIX \".so.1\"#g" $LIB_PATH/$GCC/$GCC_DIR/gcc/config/riscv/linux.h        

	# Change libstdc++.so option
        sed -i "s#^\\t-o \\$\@.*#\\t-Wl,-z,relro,-z,now,-z,noexecstack -Wtrampolines -o \$\@#g" $LIB_PATH/$GCC/$GCC_DIR/libstdc++-v3/src/Makefile.in
}

function update_config() {
	cp $SRC_DIR/configs/config_* $WORK_DIR/
	sed -i "s#^CT_LINUX_CUSTOM_LOCATION.*#CT_LINUX_CUSTOM_LOCATION=\"$LIB_PATH/kernel\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_BINUTILS_CUSTOM_LOCATION.*#CT_BINUTILS_CUSTOM_LOCATION=\"$LIB_PATH/$BINUTILS/$BINUTILS_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_GLIBC_CUSTOM_LOCATION.*#CT_GLIBC_CUSTOM_LOCATION=\"$LIB_PATH/$GLIBC/$GLIBC_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_MUSL_CUSTOM_LOCATION.*#CT_MUSL_CUSTOM_LOCATION=\"$LIB_PATH/$MUSLC/$MUSLC_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_GCC_CUSTOM_LOCATION.*#CT_GCC_CUSTOM_LOCATION=\"$LIB_PATH/$GCC/$GCC_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_GDB_CUSTOM_LOCATION.*#CT_GDB_CUSTOM_LOCATION=\"$LIB_PATH/$GDB/$GDB_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_GMP_CUSTOM_LOCATION.*#CT_GMP_CUSTOM_LOCATION=\"$LIB_PATH/$GMP/$GMP_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_ISL_CUSTOM_LOCATION.*#CT_ISL_CUSTOM_LOCATION=\"$LIB_PATH/$ISL/$ISL_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_MPC_CUSTOM_LOCATION.*#CT_MPC_CUSTOM_LOCATION=\"$LIB_PATH/$MPC/$MPC_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_MPFR_CUSTOM_LOCATION.*#CT_MPFR_CUSTOM_LOCATION=\"$LIB_PATH/$MPFR/$MPFR_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_EXPAT_CUSTOM_LOCATION.*#CT_EXPAT_CUSTOM_LOCATION=\"$LIB_PATH/$EXPAT/$EXPAT_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_LIBICONV_CUSTOM_LOCATION.*#CT_LIBICONV_CUSTOM_LOCATION=\"$LIB_PATH/$LIBICONV/$LIBICONV_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_GETTEXT_CUSTOM_LOCATION.*#CT_GETTEXT_CUSTOM_LOCATION=\"$LIB_PATH/$GETTEXT/$GETTEXT_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_NCURSES_CUSTOM_LOCATION.*#CT_NCURSES_CUSTOM_LOCATION=\"$LIB_PATH/$NCURSES/$NCURSES_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_ZLIB_CUSTOM_LOCATION.*#CT_ZLIB_CUSTOM_LOCATION=\"$LIB_PATH/$ZLIB/$ZLIB_DIR\"#g" $WORK_DIR/config_*
	sed -i "s#^CT_ZSTD_CUSTOM_LOCATION.*#CT_ZSTD_CUSTOM_LOCATION=\"$LIB_PATH/$ZSTD/$ZSTD_DIR\"#g" $WORK_DIR/config_*
}

main()
{
	set -e
	SRC_DIR="$(pwd)"
	SRC_DIR="$(realpath ${SRC_DIR})"
	source "${SRC_DIR}/configs/config.xml"
	readonly LIB_PATH="$SRC_DIR/open_source"
	WORK_DIR=$SRC_DIR

	update_feature
	update_config

	cd $SRC_DIR
	echo "Prepare done! Now you can run: (not in root please)"
	echo "'cp config_arm32 .config && ct-ng build' for build arm"
	echo "'cp config_aarch64 .config && ct-ng build' for build arm64"
	echo "'cp config_x86_64 .config && ct-ng build' for build x86_64"
	echo "'cp config_riscv64 .config && ct-ng build' for build riscv64"
	echo "'cp config_aarch64-musl .config && ct-ng build' for build muslc_aarch64"
}

main "$@"
