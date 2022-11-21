# make ros libs compatible with lib64
do_configure:prepend:class-target() {
    if [[ "${libdir}" =~ "lib64" ]]; then
        cat ${S}/cmake/rosidl_generator_py_generate_interfaces.cmake | grep "DESTINATION lib64" || sed -i 's:DESTINATION lib:DESTINATION lib64:g' ${S}/cmake/rosidl_generator_py_generate_interfaces.cmake
        cat ${S}/cmake/rosidl_generator_py_generate_interfaces.cmake | grep "/Lib64/" || sed -i 's:/Lib/:/Lib64/:g' ${S}/cmake/rosidl_generator_py_generate_interfaces.cmake
        cat ${S}/cmake/rosidl_generator_py_generate_interfaces.cmake | grep "/lib64/" || sed -i 's:/lib/:/lib64/:g' ${S}/cmake/rosidl_generator_py_generate_interfaces.cmake
        cat ${S}/rosidl_generator_py-extras.cmake.in | grep "lib64/rosidl_" || sed -i 's:lib/rosidl_:lib64/rosidl_:g' ${S}/rosidl_generator_py-extras.cmake.in
    fi
}

