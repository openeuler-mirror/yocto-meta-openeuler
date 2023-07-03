ROS_BUILD_DEPENDS:remove = " \
    joy-linux \
    teleop-twist-joy \
"

FILES:${PN} += "/usr/share"

do_configure:prepend:class-target() {
    if [ -f ${S}/CMakeLists.txt ]; then
        cat ${S}/CMakeLists.txt | grep "joy_linux" && sed -i 's:find_package(joy_linux REQUIRED)::g' ${S}/CMakeLists.txt
        cat ${S}/CMakeLists.txt | grep "teleop_twist_joy" && sed -i 's:find_package(teleop_twist_joy REQUIRED)::g' ${S}/CMakeLists.txt
    fi
}
