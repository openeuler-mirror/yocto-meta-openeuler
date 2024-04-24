DESCRIPTION = "Qt Web Browser"
LICENSE = "GPL-3.0"
LIC_FILES_CHKSUM = "file://LICENSE.GPLv3;md5=a40e2bb02b1ac431f461afd03ff9d1d6"

OPENEULER_LOCAL_NAME = "oee_archive"

inherit qmake5 systemd
# require recipes-qt/qt5/qt5-git.inc

# QT_GIT = "git://github.com/qtproject"
# QT_MODULE = "qt-apps-qtwebbrowser"
# QT_MODULE_BRANCH = "dev"

SRC_URI += " \
    file://0001-project-fix-install-path-for-poky.patch \
    file://0002-qtwebbrowser-add-application-mode.patch \
"
# use manual start
#    file://wait-for-server.sh 
#    file://${PN}.service

SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/${BPN}/v5.15.1_QtAS.tar.gz \
"

S = "${WORKDIR}/qt-apps-qtwebbrowser-${PV}_QtAS"

SRCREV = "023733af5523a5ad84359926224fa106001215f4"

DEPENDS = "qtbase qtdeclarative qtwebengine"

PACKAGECONFIG ?= ""
PACKAGECONFIG[desktop] = "-DDESKTOP_BUILD,,"

# SYSTEMD_SERVICE:${PN} = "${PN}.service"

# use manual start
# do_install:append() {
#     install -Dm 0644 ${WORKDIR}/${PN}.service ${D}${systemd_system_unitdir}/${PN}.service
#     install -Dm 0755 ${WORKDIR}/wait-for-server.sh ${D}${bindir}/wait-for-server.sh
# }

RDEPENDS:${PN} += " \
    qtvirtualkeyboard \
    qtquickcontrols-qmlplugins \
    qtwebengine-qmlplugins \
    qtgraphicaleffects-qmlplugins \
    qtmultimedia-qmlplugins \
    ca-certificates \
    ttf-dejavu-common \
    ttf-dejavu-sans \
    ttf-dejavu-sans-mono \
"
