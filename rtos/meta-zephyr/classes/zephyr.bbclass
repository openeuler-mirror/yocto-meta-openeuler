inherit terminal
inherit python3native

PYTHONPATH="${STAGING_DIR_HOST}${libdir}/${PYTHON_DIR}/site-packages"
DEPENDS += "python3-pyelftools-native python3-pyyaml-native python3-pykwalify-native python3-packaging-native"

OE_TERMINAL_EXPORTS += "HOST_EXTRACFLAGS HOSTLDFLAGS TERMINFO CROSS_CURSES_LIB CROSS_CURSES_INC"
HOST_EXTRACFLAGS = "${BUILD_CFLAGS} ${BUILD_LDFLAGS}"
HOSTLDFLAGS = "${BUILD_LDFLAGS}"
CROSS_CURSES_LIB = "-lncurses -ltinfo"
CROSS_CURSES_INC = '-DCURSES_LOC="<curses.h>"'
TERMINFO = "${STAGING_DATADIR_NATIVE}/terminfo"

KCONFIG_CONFIG_COMMAND ??= "menuconfig"
ZEPHYR_BOARD ?= "${MACHINE}"


# just need the compiler, no need of glibc and runtime libraries which are for linux
INHIBIT_DEFAULT_DEPS = "1"
DEPENDS += "virtual/${TARGET_PREFIX}gcc"

# in bitbake.conf line 519
# export CC = "${CCACHE}${HOST_PREFIX}gcc ${HOST_CC_ARCH}${TOOLCHAIN_OPTIONS}
# no need of ${HOST_CC_ARCH}${TOOLCHAIN_OPTIONS} to impact the compile of zephyr
# just need the compiler. If some extra options are required, try to add here
HOST_CC_ARCH = ""
TOOLCHAIN_OPTIONS = ""

# qemuboot writes into IMGDEPLOYDIR, force to write to DEPLOY_DIR_IMAGE
IMGDEPLOYDIR = "${DEPLOY_DIR_IMAGE}"

python () {
    # Translate MACHINE into Zephyr BOARD
    # Zephyr BOARD is basically our MACHINE, except we must use "-" instead of "_"
    board = d.getVar('ZEPHYR_BOARD', True)
    board = board.replace('-', '_')
    d.setVar('BOARD',board)
}

python do_menuconfig() {
    os.chdir(d.getVar('B', True))
    configdir = d.getVar('B', True)
    bb.warn("configdir:{}".format(configdir))
    try:
        mtime = os.path.getmtime(configdir +"/.config")
    except OSError:
        mtime = 0

    oe_terminal("${SHELL} -c \"ZEPHYR_BASE=%s ninja %s; if [ \$? -ne 0 ]; then echo 'Command failed.'; \
                printf 'Press any key to continue... '; \
                read r; fi\"" % (d.getVar('ZEPHYR_BASE', True),d.getVar('KCONFIG_CONFIG_COMMAND', True)),
                d.getVar('PN', True) + ' Configuration', d)

    try:
        newmtime = os.path.getmtime(configdir +"/.config")
    except OSError:
        newmtime = 0

    if newmtime > mtime:
        bb.warn("Configuration changed, recompile will be forced")
        bb.build.write_taint('do_compile', d)
}
do_menuconfig[depends] += "ncurses-native:do_populate_sysroot"
do_menuconfig[nostamp] = "1"
do_menuconfig[dirs] = "${B}"
addtask menuconfig after do_configure

python do_devshell:prepend () {
    # Most likely we need to manually edit prj.conf...
    os.chdir(d.getVar('ZEPHYR_SRC_DIR', True))
}
