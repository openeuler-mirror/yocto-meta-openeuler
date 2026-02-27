# main bbfile: yocto-poky/meta/recipes-support/popt/popt_1.18.bb

PV = "2.56.5"
# note: 2.56.5 need nlohmann-json >= 3.12.0 

# need common DEPENDS in bb recipes
# use openuelr's bin
DEPENDS += " libpng libgl-bin libglu-bin glfw-bin gtk3-bin libglvnd-bin "

# we have use bin library for compile, or need x11 opengl feature enable
# DEPENDS += " mesa "

SRC_URI:remove = "git://github.com/IntelRealSense/librealsense.git;protocol=https;branch=master;rev=e196cefa896e312d79c2df400c7623aa1e9c62ac"

inherit oee-archive
OEE_ARCHIVE_SUB_DIR = "librealsense2"

SRC_URI:prepend = " \
    file://v2.56.5.tar.gz \
"

S = "${WORKDIR}/librealsense-${PV}"

# rewite graphical feature, need common EXTRA_OECMAKE of -DBUILD_GRAPHICAL_EXAMPLES and -DBUILD_GLSL_EXTENSIONS
EXTRA_OECMAKE += " \
    -DBUILD_GRAPHICAL_EXAMPLES:BOOL=ON \
    -DBUILD_GLSL_EXTENSIONS:BOOL=ON \
"

FILES:${PN} += " \
    ${bindir}/rs-on-chip-calib \
"

# ignore ldlink of x11 symbols for compile time
LDFLAGS += " -Wl,--warn-unresolved-symbols "

do_install:append() {
    # Remove preset file
    rm -rf ${D}/home/
}

# ignore follow dev-deps, but it should depends on openeuler's real pkg
#QA Issue: librealsense2-tools rdepends on glfw-bin-dev [dev-deps]
#QA Issue: librealsense2-tools rdepends on libglu-bin-dev [dev-deps]
#QA Issue: librealsense2-debug-tools rdepends on glfw-bin-dev [dev-deps]
#QA Issue: librealsense2-examples rdepends on glfw-bin-dev [dev-deps]
#QA Issue: librealsense2-examples rdepends on libglu-bin-dev [dev-deps]
#QA Issue: librealsense2 rdepends on glfw-bin-dev [dev-deps]
INSANE_SKIP:${PN} += "dev-deps"
INSANE_SKIP:${PN}-debug-tools += "dev-deps"
INSANE_SKIP:${PN}-tools += "dev-deps"
INSANE_SKIP:${PN}-examples += "dev-deps"
