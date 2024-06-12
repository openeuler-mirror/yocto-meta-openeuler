# main bbfile: yocto-poky/meta/recipes-graphics/xorg-lib/xkeyboard-config_2.32.bb

# version in src-openEuler
PV = "2.38"

SRC_URI = "file://${BP}.tar.xz \
        file://backport-run-the-pytest-test-suite-as-part-of-meson-test.patch \
        "

# use nativesdk's python3 tool
DEPENDS_remove = "python3-native"
PYTHON_remove = "${STAGING_BINDIR_NATIVE}/python3-native/python3"

SRC_URI[sha256sum] = "657fd790d6dcf781cd395de4cf726120a5b0f93ba91dfb2628bcc70ae8b1d3bc"
