# Override of poky's python3targetconfig.bbclass for openeuler.
#
# Problem: on aarch64, openeuler sets baselib = "lib64" (from BASE_LIB:tune-aarch64),
# so _sysconfigdata.py is installed under usr/lib64/python-sysconfigdata/.
#
# For ROS recipes, ros_distro_humble.bbclass rewrites libdir from /usr/lib64 to /usr/lib
# at RecipePreFinalise (to match ROS upstream's hard-coded lib install paths).
# As a result, STAGING_LIBDIR = recipe-sysroot/usr/lib for all ROS target recipes,
# while _sysconfigdata.py still lives under usr/lib64/python-sysconfigdata/.
#
# Poky's original setup_target_config() only appends ${STAGING_LIBDIR}/python-sysconfigdata
# to PYTHONPATH, so Python cannot find the _sysconfigdata module when libdir != lib64.
#
# Fix: also append ${STAGING_DIR_HOST}${exec_prefix}/lib64/python-sysconfigdata,
# which is an absolute path that always resolves to usr/lib64/python-sysconfigdata
# regardless of whether libdir has been modified by ros_libdir_set or not.
# On architectures without lib64 (e.g. x86, riscv with lp64d) this path simply does
# not exist and Python silently skips it, so there is no regression.

inherit python3native

EXTRA_PYTHON_DEPENDS ?= ""
EXTRA_PYTHON_DEPENDS:class-target = "python3"
DEPENDS:append = " ${EXTRA_PYTHON_DEPENDS}"

setup_target_config() {
        export _PYTHON_SYSCONFIGDATA_NAME="_sysconfigdata"
        export PYTHONPATH=${STAGING_LIBDIR}/python-sysconfigdata:${STAGING_DIR_HOST}${exec_prefix}/lib64/python-sysconfigdata:$PYTHONPATH
        export PATH=${STAGING_EXECPREFIXDIR}/python-target-config/:$PATH
}

do_configure:prepend:class-target() {
        setup_target_config
}

do_compile:prepend:class-target() {
        setup_target_config
}

do_install:prepend:class-target() {
        setup_target_config
}

do_configure:prepend:class-nativesdk() {
        setup_target_config
}

do_compile:prepend:class-nativesdk() {
        setup_target_config
}

do_install:prepend:class-nativesdk() {
        setup_target_config
}
