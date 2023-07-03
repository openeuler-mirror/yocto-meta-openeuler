DESCRIPTION = "Jailhouse partitioning hypervisor"
HOMEPAGE = "https://github.com/siemens/jailhouse"
LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://COPYING;md5=9fa7f895f96bde2d47fd5b7d95b6ba4d"

OPENEULER_REPO_NAME = "Jailhouse"
OPENEULER_BRANCH = "master"

PV = "0.12"
SRC_URI = " \
	file://${BP}.tar.gz \
	file://cells/ \
	"

DEPENDS = " \
	virtual/kernel \
	make-native \
	python3-mako-native \
	dtc-native \
	python3-blinker\
	python3-click \
	python3-psutil \
	"

inherit module python3native bash-completion setuptools3

B = "${S}"

COMPATIBLE_MACHINE = "qemu-aarch64|qemu-arm|raspberrypi4-64"

JH_DATADIR ?= "${datadir}/jailhouse"
CELL_DIR ?= "${JH_DATADIR}/cells"
INMATES_DIR ?= "${JH_DATADIR}/inmates"
DTS_DIR ?= "${JH_DATADIR}/cells/dts"

JH_CELLS_raspberrypi4-64 = "rpi4"
JH_CELLS_qemu-aarch64 = "qemu-arm64"

do_configure:prepend() {
	if ls ${WORKDIR}/cells/${ARCH}/${JH_CELLS}*.c 1>/dev/null 2>&1; then
		cp -f ${WORKDIR}/cells/${ARCH}/${JH_CELLS}*.c ${S}/configs/${ARCH}/
	fi
}

EXTRA_OEMAKE = "V=0 ARCH=${ARCH} CROSS_COMPILE=${TARGET_PREFIX} \
		KDIR=${STAGING_KERNEL_BUILDDIR}"

do_compile() {
	oe_runmake
}

do_install() {
	# Install pyjailhouse python modules needed by the tools
	distutils3_do_install

	# We want to install the python tools, but we do not want to use pip...
	# At least with v0.10, we can work around this with
	# 'PIP=":" PYTHON_PIP_USEABLE=yes'
	oe_runmake PIP=: PYTHON=python3 PYTHON_PIP_USEABLE=yes\
	INSTALL_MOD_PATH=${D}${root_prefix} \
	firmwaredir=${nonarch_base_libdir}/firmware \
	DESTDIR=${D} install

	install -d ${D}${CELL_DIR}
	install -m 0644 ${B}/configs/${ARCH}/${JH_CELLS}*.cell ${D}${CELL_DIR}/

	install -d ${D}${INMATES_DIR}
	install -m 0644 ${B}/inmates/demos/${ARCH}/*.bin ${D}${INMATES_DIR}

	if [ ${JH_ARCH}  != "x86" ]; then
		install -d ${D}${DTS_DIR}
		install -m 0644 ${B}/configs/${ARCH}/dts/*${JH_CELLS}.dtb ${D}${DTS_DIR}
	fi
}

PACKAGE_BEFORE_PN = "kernel-module-jailhouse pyjailhouse ${PN}-tools ${PN}-demos"
FILES:${PN} += "${nonarch_base_libdir}/firmware ${libexecdir} ${sbindir} ${JH_DATADIR}"
KERNEL_MODULE_AUTOLOAD += "jailhouse"
