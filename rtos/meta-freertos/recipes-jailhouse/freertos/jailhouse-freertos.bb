SUMMARY = "FreeRTOS Demo"
DESCRIPTION = "FreeRTOS Demo"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://license.txt;md5=473b63a963910267fc231e5a65bf1a2d \
                    "

SRC_URI = "git://github.com/FreeRTOS/FreeRTOS-Kernel.git;branch=main;protocol=https \
           file://Jailhouse_FreeRTOS_demo.tar.gz   \
"
SRCREV = "309a18a03adab1eaca5d86654dd4e1075ee49e7a"
S = "${WORKDIR}/Jailhouse_FreeRTOS_demo"

EXTRA_OEMAKE = "CROSS=${TARGET_PREFIX} FREERTOS_SRC=${WORKDIR}/git"

do_compile() {
	oe_runmake
}

do_install() {
    mkdir ${D}/Jailhouse_FreeRTOS_demo
	cp ${S}/FreeRTOS.bin ${D}/Jailhouse_FreeRTOS_demo/
}

FILES:${PN} = "Jailhouse_FreeRTOS_demo"
