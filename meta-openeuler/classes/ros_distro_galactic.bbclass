ROS_DISTRO = "galactic"

inherit ${ROS_DISTRO_TYPE}_distro
inherit openeuler_ros_source

# make ros libs compatible with lib64
do_configure:prepend:class-target() { 
    if [ -f ${S}/CMakeLists.txt ] && [[ "${libdir}" =~ "lib64" ]]; then
        cat ${S}/CMakeLists.txt | grep "DESTINATION lib\${LIB_SUFFIX}" || sed -i 's:DESTINATION lib:DESTINATION lib\${LIB_SUFFIX}:g' ${S}/CMakeLists.txt
        cat ${S}/CMakeLists.txt | grep "LIB_INSTALL_DIR lib\${LIB_SUFFIX}" || sed -i 's:LIB_INSTALL_DIR lib:LIB_INSTALL_DIR lib\${LIB_SUFFIX}:g' ${S}/CMakeLists.txt
    fi
}

