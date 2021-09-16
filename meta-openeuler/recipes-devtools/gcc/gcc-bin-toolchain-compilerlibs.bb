# Copyright (C) Huawei Technologies Co., Ltd. 2020. All rights reserved.
# Description: Extract libgcc and compiler-rt from toolchain
# Author: Huawei OS Kernel Lab
# Create: Mon Sep 07 13:39:28 2020

inherit eulertoolchain
require gcc-bin-toolchain.inc

INHIBIT_DEFAULT_DEPS = "1"
DEPENDS = "virtual/${EULER_TOOLCHAIN_TARGET_PREFIX}gcc \
           virtual/${EULER_TOOLCHAIN_TARGET_PREFIX}g++"
#DEPENDS = "virtual/${TARGET_PREFIX}gcc \
#           virtual/${TARGET_PREFIX}g++"

PROVIDES = "virtual/${EULER_TOOLCHAIN_TARGET_PREFIX}compilerlibs gcc-runtime libstdc++ libgcc-initial"
#PROVIDES = "gcc-runtime libstdc++ libgcc-initial virtual/${TARGET_PREFIX}compilerlibs"


# Insert lib and usr/lib into SYSROOT_DIRS so these 2 dir
# will be found by building of bb depends on this bb. It
# is required because we set BASELIB to lib32, which makes
# yocto stage lib32 and usr/lib32. However, compiler has
# built-in path to find libgcc, which is /lib or /usr/lib.
#LIBDIR_COMPAT_EXTRA = "${@ '' if not is_compat(d) else '/lib /usr/lib'}"
#SYSROOT_DIRS += "${LIBDIR_COMPAT_EXTRA}"

do_install () {
#exit 0
    bbnote "Installing libgcc/libclang from Compiler CPU binary toolchain"
    install -m 0755 -d ${D}${libdir_native}/${EULER_TOOLCHAIN_GCC_PATH_INNER}

    finddirs=''
    test -d ${B}/${EULER_TOOLCHAIN_SYSNAME}/lib     && finddirs="$finddirs ${B}/${EULER_TOOLCHAIN_SYSNAME}/lib"
    test -d ${B}/${EULER_TOOLCHAIN_SYSNAME}/lib64   && finddirs="$finddirs ${B}/${EULER_TOOLCHAIN_SYSNAME}/lib64"
    test -d ${B}/lib/${EULER_TOOLCHAIN_GCC_PATH}    && finddirs="$finddirs ${B}/lib/${EULER_TOOLCHAIN_GCC_PATH}"
    test -d ${B}/lib64/${EULER_TOOLCHAIN_GCC_PATH}  && finddirs="$finddirs ${B}/lib64/${EULER_TOOLCHAIN_GCC_PATH}"

    find $finddirs \
         -name '*.o' \
                -o -name 'libgcc*.a' \
                -o -name 'libc++*.a' \
                -o -name 'libstdc++*.a' \
                -o -name 'libclang_rt*.a'  \
                -o -name 'libunwind*.a*'  \
                -o -name 'libgcc*.so*' \
                -o -name 'libc++*.so*' \
                -o -name 'libstdc++*.so*' \
                -o -name 'libclang_rt*.so*'  \
                -o -name 'libunwind*.so*'  |
        xargs sh -c 'cp -P --preserve=mode,timestamps,links -v $@ ${D}${libdir_native}/${EULER_TOOLCHAIN_GCC_PATH_INNER}; \
		chmod 644 $1' sh

    # Remove executable permission for crt*.o to avoid being stripped
    for f in ${D}${libdir_native}/${EULER_TOOLCHAIN_GCC_PATH_INNER}/*.o
    do
        chmod 644 $f
    done
    for f in ${D}${libdir_native}/${EULER_TOOLCHAIN_GCC_PATH_INNER}/*.so*
    do
        chmod 644 $f
    done

    mkdir -p ${D}${base_libdir}
    mkdir -p ${D}${libdir}
    for f in ${D}${libdir_native}/${EULER_TOOLCHAIN_GCC_PATH_INNER}/*.so*
    do
        destdir=${libdir}
        if echo $f | grep 'libgcc\|libclang_rt\|libunwind_s'
        then
            destdir=${base_libdir}
        fi

        bn=$(basename $f)
        mv $f ${D}$destdir
        rel=$(realpath --relative-to=$(dirname $f) ${D}$destdir)
        ln -s $rel/$bn $(dirname $f)
    done
    rm -r ${D}${libdir_native}/${EULER_TOOLCHAIN_SYSNAME}
}

# Package will be called as libgcc-s1. Don't know why.
# This makes ldconfig triggered. We need to remove
# ldconfig from our DISTRO_FEATURES.
FILES_${PN} = " \
    ${base_libdir}/*.so \
    ${base_libdir}/*.so.*[0-9] \
    ${libdir}/*.so \
    ${libdir}/*.so.*[0-9] \
"

FILES_${PN}-dev = " \
    ${libdir_native}/${EULER_TOOLCHAIN_GCC_PATH_INNER}/*.so.* \
    ${libdir_native}/${EULER_TOOLCHAIN_GCC_PATH_INNER}/*.so \
    ${libdir_native}/${EULER_TOOLCHAIN_GCC_PATH_INNER}/*.py \
    ${base_libdir}/*.py \
    ${libdir}/*.py \
"
FILES_${PN}-staticdev = " \
    ${libdir_native}/${EULER_TOOLCHAIN_GCC_PATH_INNER}/*.o \
    ${libdir_native}/${EULER_TOOLCHAIN_GCC_PATH_INNER}/*.a \
"

INSANE_SKIP = "file-rdeps ldflags arch"
# POPULATESYSROOTDEPS contains cross toolchain, which
# is different from real toolchain this compilerlib belongs to,
# in case when we are aarch64 and needs arm compilerlib for compat
# building. See staging.bbclass.
POPULATESYSROOTDEPS_class-target = ""
INHIBIT_SYSROOT_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

ERROR_QA_remove += "dev-elf dev-so"
WARN_QA_remove += "libdir"

INSANE_SKIP += "installed-vs-shipped"
do_package_qa[noexec] = "1"

SYSROOT_DIRS_append =" \
    ${sublibdir} \
    ${subincludedir} \
"
SYSROOT_DIRS_NATIVE_append = "${subbindir}"
