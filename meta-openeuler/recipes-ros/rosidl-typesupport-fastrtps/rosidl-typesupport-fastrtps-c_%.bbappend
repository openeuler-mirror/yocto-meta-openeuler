# make ros libs compatible with lib64
do_configure:prepend:class-target() {
    if [[ "${libdir}" =~ "lib64" ]]; then
        cat ${S}/cmake/rosidl_typesupport_fastrtps_c_generate_interfaces.cmake | grep "DESTINATION lib64" || sed -i 's:DESTINATION lib:DESTINATION lib64:g' ${S}/cmake/rosidl_typesupport_fastrtps_c_generate_interfaces.cmake
        cat ${S}/rosidl_typesupport_fastrtps_c-extras.cmake.in | grep "lib64/rosidl_" || sed -i 's:lib/rosidl_:lib64/rosidl_:g' ${S}/rosidl_typesupport_fastrtps_c-extras.cmake.in
    fi
}

