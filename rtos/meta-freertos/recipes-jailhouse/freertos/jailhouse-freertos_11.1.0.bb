SUMMARY = "FreeRTOS Demo"
DESCRIPTION = "FreeRTOS Demo"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://license.txt;md5=473b63a963910267fc231e5a65bf1a2d \
                    "

SRC_URI = "https://github.com/FreeRTOS/FreeRTOS-Kernel/releases/download/V${PV}/FreeRTOS-KernelV${PV}.zip \
           file://Jailhouse_FreeRTOS_demo.tar.gz   \
"

SRC_URI[sha256sum] = "eebd58aa71a623c9381f25f77b708c0ed14ef995a8913e2460fe9f286bb271eb"

S = "${WORKDIR}/Jailhouse_FreeRTOS_demo"

EXTRA_OEMAKE = "CROSS=${TARGET_PREFIX} FREERTOS_SRC=${WORKDIR}/FreeRTOS-KernelV${PV} \
    FREERTOS_PORT_SRC=${WORKDIR}/FreeRTOS-KernelV${PV}/portable/GCC/ARM_AARCH64"

do_compile() {
	oe_runmake
}

do_install() {
    mkdir ${D}/Jailhouse_FreeRTOS_demo
	cp ${S}/FreeRTOS.bin ${D}/Jailhouse_FreeRTOS_demo/
}

FILES:${PN} = "Jailhouse_FreeRTOS_demo"