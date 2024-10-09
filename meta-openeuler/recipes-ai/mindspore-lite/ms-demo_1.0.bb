DESCRIPTION = "Application demo for mindspore-lite"
AUTHOR = "Huawei Technologies Co., Ltd"
LICENSE = "CLOSED"

SRC_URI = " \
file://demo-src \
https://download-mindspore.osinfra.cn/model_zoo/official/lite/quick_start/mobilenetv2.ms;name=model \
"

SRC_URI[model.sha256sum] = "5a7ccd53bf92d8b294a703a1302d4230a311b2d19a8d212eedd65ff6838cfa84"

# Source directory
S = "${WORKDIR}/ms-demo"

DEPENDS = "mindspore-lite"

# Inherit pkg
inherit cmake

do_configure:prepend(){
    cp -rf ${WORKDIR}/demo-src/* ${S}
    cp ${WORKDIR}/mobilenetv2.ms ${S}/model
}

# Install the demo binary
do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/ms-lite-demo ${D}${bindir}/
    install -d ${D}/usr/model
    install -m 0755 ${WORKDIR}/mobilenetv2.ms ${D}/usr/model
}

# Specify files to package
FILES:${PN} = "${bindir}/ms-lite-demo /usr/model"
