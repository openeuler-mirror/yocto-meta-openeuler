ROS_DISTRO = "humble"

inherit ${ROS_DISTRO_TYPE}_distro
inherit openeuler_source
inherit pkgconfig

# There are a large number of non-standard configurations with the fixed libdir directory as lib in the ROS upstream software package. 
# At present, we can't find a suitable conventional method to adapt our libdir. 
# As a workaround, we use lib as the library directory for the ROS package. 
# we may need to consider the situation that riscv64 customized libdir is lp64d in the future.
python ros_libdir_set() {
    d.setVar('oldroslibdir', d.getVar('libdir'))
    pn = e.data.getVar("PN")      
    if pn.endswith("-native"):
        return
    d.setVar('libdir', d.getVar('libdir').replace('64', ''))
    d.setVar('baselib', d.getVar('baselib').replace('64', ''))
}

addhandler ros_libdir_set
ros_libdir_set[eventmask] = "bb.event.RecipePreFinalise"

# some depend pkgs may not inherit this class, it may under lib64 of oldroslibdir.
PKG_CONFIG_PATH:append:class-target = ":${PKG_CONFIG_SYSROOT_DIR}/${oldroslibdir}/pkgconfig"

# fix _sysconfigdata not found error, after inherit setuptools3, see yocto-poky/meta/classes/python3targetconfig.bbclass
# do_install:remove:class-target() {
#         export _PYTHON_SYSCONFIGDATA_NAME="_sysconfigdata"
# }

# do_compile:remove:class-target() {
#         export _PYTHON_SYSCONFIGDATA_NAME="_sysconfigdata"
# }

# do_configure:remove:class-target() {
#         export _PYTHON_SYSCONFIGDATA_NAME="_sysconfigdata"
# }

# Fix set(CMAKE_CXX_STANDARD 14) invalid with cmake version 3.22
EXTRA_OECMAKE += " -DCMAKE_CXX_STANDARD_REQUIRED=ON "

# python package in ros should be installed in /usr/lib, but in openeuler, it will be packaged
# in /usr/lib64, so we mv lib64 content to lib
do_install:append (){
    if [ -d ${D}/usr/lib64 ];then
        if [ ! -d ${D}/usr/lib ];then
            install -d ${D}/usr/lib/
        fi
        mv ${D}/usr/lib64/* ${D}/usr/lib
        rm -rf ${D}/usr/lib64
    fi
}
