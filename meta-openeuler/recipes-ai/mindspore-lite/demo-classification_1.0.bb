DESCRIPTION = "Application demo for mindspore-lite"
AUTHOR = "Huawei Technologies Co., Ltd"
LICENSE = "CLOSED"

SRC_URI = " \
file://demo-class \
file://pictures/ \
https://download-mindspore.osinfra.cn/model_zoo/official/lite/quick_start/mobilenetv2.ms;name=model \
"

SRC_URI[model.sha256sum] = "5a7ccd53bf92d8b294a703a1302d4230a311b2d19a8d212eedd65ff6838cfa84"

# Source directory
S = "${WORKDIR}/demo-classification"

DEPENDS = "mindspore-lite opencv"

# Inherit pkg
inherit cmake

EXTRA_OECMAKE += "-DCMAKE_CXX_FLAGS=-I${STAGING_INCDIR}/opencv4"
EXTRA_OECMAKE += "-DCMAKE_EXE_LINKER_FLAGS=-L${STAGING_LIBDIR}"

do_configure:prepend(){
    cp -rf ${WORKDIR}/demo-class/* ${S}
    cp ${WORKDIR}/mobilenetv2.ms ${S}/model
}

do_configure[depends] += "opencv:do_populate_sysroot mindspore-lite:do_populate_sysroot"

# Install the demo binary
do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/ms-demo-class ${D}${bindir}/
    install -d ${D}/usr/model
    install -m 0755 ${WORKDIR}/mobilenetv2.ms ${D}/usr/model
    install -d ${D}/usr/pictures
    cp -r ${WORKDIR}/pictures/* ${D}/usr/pictures/
}

# Specify files to package
FILES:${PN} = "${bindir}/ms-demo-class /usr/model /usr/pictures"
