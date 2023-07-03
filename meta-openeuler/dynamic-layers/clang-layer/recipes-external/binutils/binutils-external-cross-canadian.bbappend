# some binutils still using gcc compiled
binutils_binaries = "as ld ld.bfd ld.gold elfedit addr2line"
# using llvm binutils
clang_binutils = "ar nm objcopy objdump ranlib strip cxxfilt readelf size strings readobj"
# add llvm-* binutils
FILES:${PN} += "\
    ${bindir}/ld* \
    ${bindir}/lld* \
    ${@' '.join('${bindir}/llvm-' + i for i in '${clang_binutils}'.split())} \
"

# add ${TARGET_PREFIX}{binutils} links to llvm-{binutils}
do_install:append () {
    for i in ${D}${bindir}/llvm-*; do
        if [ -e "$i" ]; then
            j="$(basename "$i")"
            [[ -e "${D}${bindir}/${TARGET_PREFIX}${j#llvm-}" ]] && continue
            ln -sv "$j" "${D}${bindir}/${TARGET_PREFIX}${j#llvm-}"
        fi
    done
}

python add_llvm_files_links () {
    prefix = 'llvm-'
    full_prefix = os.path.join(d.getVar('bindir'), prefix)
    new_prefix = d.getVar('TARGET_PREFIX')
    for pkg in d.getVar('PACKAGES').split():
        files = (d.getVar('FILES:%s' % pkg) or '').split()
        new_files = []
        for f in files:
            if f.startswith(full_prefix):
                new_files.append(f.replace(prefix, new_prefix))
        if new_files:
            d.appendVar('FILES:%s' % pkg, ' ' + ' '.join(new_files))
}
do_package[prefuncs] += "add_llvm_files_links"
