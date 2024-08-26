PV = "20230802.1"

SRC_URI = " \
        file://${BP}.tar.gz \
        file://abseil-cpp-20210324.2-sw.patch \
        "

EXTRA_OECMAKE += " \
	-DABSL_ENABLE_INSTALL=ON \
	-DCMAKE_SHARED_LINKER_FLAGS="-Wl,--as-needed" \
	-DCMAKE_BUILD_TYPE=RelWithDebInfo \
"

S = "${WORKDIR}/${BP}"

SYSROOT_DIRS:append:class-nativesdk:mingw32 = " ${bindir}"

PACKAGES_DYNAMIC = "^libabsl-*"
PACKAGES_DYNAMIC:class-native = ""

PACKAGESPLITFUNCS =+ "split_dynamic_packages"

python split_dynamic_packages() {
    libdir = d.getVar('libdir')

    libpackages = do_split_packages(
        d,
        root=libdir,
        file_regex=r'^libabsl_(.*)\.so\..*$',
        output_pattern='libabsl-%s',
        description="abseil shared library %s",
        prepend=True,
        extra_depends='',
    )
    if libpackages:
        d.appendVar('RDEPENDS:' + d.getVar('PN'), ' ' + ' '.join(libpackages))
}

ALLOW_EMPTY:${PN} = "1"
