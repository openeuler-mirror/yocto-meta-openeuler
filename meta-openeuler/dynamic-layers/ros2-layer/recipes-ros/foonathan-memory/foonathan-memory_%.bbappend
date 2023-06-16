# main bbfile: yocto-meta-ros/meta-ros2/recipes-devtools/foonathan-memory/foonathan-memory_git.bb
inherit openeuler_source

LIC_FILES_CHKSUM = "file://LICENSE;md5=b68ca6474a0f8d6c83a635ef86bcd757"

# droped under new version
EXTRA_OECMAKE:remove += " -DCOMP_CMAKE_PATH=${S}/cmake/comp "

FILES:${PN} += " ${libdir}/foonathan_memory/cmake "
