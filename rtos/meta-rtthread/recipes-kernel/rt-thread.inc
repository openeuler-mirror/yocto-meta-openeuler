### Descriptive metadata: SUMMARY,DESCRITPION, HOMEPAGE, AUTHOR, BUGTRACKER
SUMMARY = "RT-Thread "
DESCRITPION = "A well-known open source RTOS from China"
AUTHOR = ""
HOMEPAGE = "https://github.com/RT-Thread/rt-thread"
BUGTRACKER = "https://gitee.com/openeuler/yocto-meta-openeuler"
### Package manager metadata: SECTION, PRIOIRTY(only for deb, opkg)
SECTION = "RTOS"

### License metadata
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

### Inheritance and includes if needed
## rtthread is built by scons, so we need to inherit scons.bbclass
inherit scons
# linux glibc toolchain can not be used to compile rt-thread now
INHIBIT_DEFAULT_DEPS = "1"

### Build metadata: SRC_URI, SRCDATA, S, B, FILESEXTRAPATHS....
SRC_URI = "file://rt-thread/${BPN}-v${PV}.tar.gz "
SRC_URI_append_qemu-aarch64 = "file://0001-bsp-modify-the-rtconfig.py-for-openeuler.patch"

S = "${WORKDIR}/${BPN}-v${PV}"

# the software packages required in build
# rtthread needs to be built with gcc toolchain with newlibc
# it's better to use pre-built toolchain, e.g. aarch64-elf-xxx
# DEPENDS =

# according to yocto's parameters, e.g., MACHINE, ARCH, to get
# rtthread's parameters


export RTT_EXEC_PATH = "${OPENEULER_RTOS_TOOLCHAIN_DIR}"
export RTT_CC = "gcc"
export OPENEULER_RTT_GCC_PREFIX = "${OPENEULER_RTOS_TOOLCHAIN_PREFIX}"


def get_rtthread_bsp(d):

    supported_machine = {
        "qemu_aarch64": "qemu-virt64-aarch64",
    }

    machine = d.getVar("MACHINE_ARCH",True)

    if not machine in supported_machine:
        bb.error("unsupported target arch:%s" % machine)
        return ""

    return "bsp/" + supported_machine[machine]

RTTHREAD_BSPDIR = "${@get_rtthread_bsp(d)}"

# alias package name
PROVIDES += "rtthread"

### Runtime metadata
PACKAGES = "${PN}"
### Package metadata
FILES_${PN} = " \
    /firmware \
"
### Tasks for package
python () {
    d.delVar('CFLAGS')
    d.delVar('CXXFLAGS')
    d.delVar('LDFLAGS')
    d.delVar('CC')
    d.delVar('AR')
    d.delVar('LD')
    d.delVar('NM')
    d.delVar('OBJCOPY')
}

#bypass package_qa as the deleted LDFLAGS will cause error
do_package_qa() {
    echo "do package qa"
}

#bypass configure as RTT has no configure phase
do_configure() {
    :
}

#call host's scons to compile rtt. You need to install the
#host tools required by rtt
do_compile() {
    cd ${S}/${RTTHREAD_BSPDIR}
    ${STAGING_BINDIR_NATIVE}/scons ${PARALLEL_MAKE} || \
	die "scons build execution failed."
    cd -
}

do_install() {
    install -d ${D}/firmware
    install -m 644 -D ${S}/${RTTHREAD_BSPDIR}/rtthread.* ${D}/firmware
}
