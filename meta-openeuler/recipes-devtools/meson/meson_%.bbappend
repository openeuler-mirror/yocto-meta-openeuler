
PV = "1.3.1"

# add patches from new poky under meta-openeluer
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:prepend = "file://${PV}.tar.gz \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"


# sync from 1.3.1.bb
def generate_native_link_template(d):
    val = ['-L@{OECORE_NATIVE_SYSROOT}${libdir_native}',
           '-L@{OECORE_NATIVE_SYSROOT}${base_libdir_native}',
           '-Wl,-rpath-link,@{OECORE_NATIVE_SYSROOT}${libdir_native}',
           '-Wl,-rpath-link,@{OECORE_NATIVE_SYSROOT}${base_libdir_native}',
           '-Wl,--allow-shlib-undefined'
        ]
    build_arch = d.getVar('BUILD_ARCH')
    if 'x86_64' in build_arch:
        loader = 'ld-linux-x86-64.so.2'
    elif 'i686' in build_arch:
        loader = 'ld-linux.so.2'
    elif 'aarch64' in build_arch:
        loader = 'ld-linux-aarch64.so.1'
    elif 'ppc64le' in build_arch:
        loader = 'ld64.so.2'
    elif 'loongarch64' in build_arch:
        loader = 'ld-linux-loongarch-lp64d.so.1'
    elif 'riscv64' in build_arch:
        loader = 'ld-linux-riscv64-lp64d.so.1'

    if loader:
        val += ['-Wl,--dynamic-linker=@{OECORE_NATIVE_SYSROOT}${base_libdir_native}/' + loader]

    return repr(val)