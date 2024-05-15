require clang-external.inc
inherit external-toolchain-cross-canadian

PN .= "-${TRANSLATED_TARGET_ARCH}"

clanglibdir = "${exec_prefix}/lib"
clangincdir = "${exec_prefix}/include"

RDEPENDS:${PN} = "binutils-external-cross-canadian-${TRANSLATED_TARGET_ARCH}"

FILES:${PN} = "\
    ${@' '.join('${bindir}/' + i for i in '${clang_binaries}'.split())} \
    ${clanglibdir}/* \
    ${clangincdir}/* \
"

# no debug package
FILES:${PN}-dbg = ""
# no need do autolibname(handle the dependency of .so libs)
# auto_libname in debian.bbclass will call ${TARGET_PREFIX}objdump to get shlibs2 related info
# for gcc-external-cross-canadian, can't find ${TARGET_PREFIX}objdump
AUTO_LIBNAME_PKGS = ""

# to prevent soft links from pointing to nonexistent locations
# it is necessary to copy the clang-17 and llvm-readobj file into the SDK
clang_binaries += "clang-17 llvm-readobj"

TARGET_CLANGCC_ARCH = "${TARGET_CC_ARCH}"

do_install:append () {
    for i in ${D}${bindir}/*; do
        if [ -e "$i" ]; then
            j="$(basename "$i")"
            target_clang_path=${D}${bindir}/${TARGET_PREFIX}$j
            [[ -e "$target_clang_path" ]] && continue
            # clang use wrapper script to call
            if [[ $j == clang* ]]; then
                execcmd="exec $j --target=${EXTERNAL_TARGET_SYS} \"\$@\""
                printf '#!/bin/sh\n' > "$target_clang_path"
                printf '%s\n' "${execcmd}" >> "$target_clang_path"
                chmod +x "$target_clang_path"
            else
                ln -sv "$j" "$target_clang_path"
            fi
        fi
    done
}

INSANE_SKIP:${PN} += "dev-so staticdev"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"


# add links toolchain such as *-clang to sdk
target_clang_binaries = ""
FILES:${PN} += "\
    ${@' '.join('${bindir}/' + i for i in '${target_clang_binaries}'.split())} \
"

python add_clang_files_links () {
    prefix = d.getVar('TARGET_PREFIX')
    clang_binaries = d.getVar('clang_binaries')

    binaries_list = clang_binaries.split()
    new_binaries_list = [prefix + i for i in binaries_list]

    d.setVar('target_clang_binaries', ' '.join(new_binaries_list))
}
do_package[prefuncs] += "add_clang_files_links"

ALL_QA:remove = "libdir"
