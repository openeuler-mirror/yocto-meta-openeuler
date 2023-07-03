PACKAGECONFIG_GL = "${@bb.utils.contains('DISTRO_FEATURES', 'x11 opengl', 'gl', \
                        bb.utils.contains('DISTRO_FEATURES',     'opengl', 'eglfs gles2', \
                                                                       '', d), d)}"
PACKAGECONFIG_GL:append = "${@bb.utils.contains('MACHINE_FEATURES', 'vc4graphics', ' kms', '', d)}"
PACKAGECONFIG_GL:append = " gbm"
PACKAGECONFIG_FONTS = "fontconfig"
PACKAGECONFIG:append = " libinput examples tslib xkbcommon"
PACKAGECONFIG:remove = "tests"

OE_QTBASE_EGLFS_DEVICE_INTEGRATION = "${@bb.utils.contains('MACHINE_FEATURES', 'vc4graphics', '', 'eglfs_brcm', d)}"

do_configure:prepend() {
    # Add the appropriate EGLFS_DEVICE_INTEGRATION
    if [ "${@d.getVar('OE_QTBASE_EGLFS_DEVICE_INTEGRATION')}" != "" ]; then
        echo "EGLFS_DEVICE_INTEGRATION = ${OE_QTBASE_EGLFS_DEVICE_INTEGRATION}" >> ${S}/mkspecs/oe-device-extra.pri
    fi
}
RDEPENDS:${PN}:append = " ${@bb.utils.contains('MACHINE_FEATURES', 'vc4graphics', '', ' userland', d)}"
DEPENDS:append = " ${@bb.utils.contains('MACHINE_FEATURES', 'vc4graphics', '', ' userland', d)}"
