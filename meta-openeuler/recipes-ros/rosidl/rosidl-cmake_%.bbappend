# make ros libs compatible with lib64
do_configure:prepend:class-target() {
    if [[ "${libdir}" =~ "lib64" ]]; then
        cat ${S}/cmake/rosidl_cmake_export_typesupport_libraries-extras.cmake.in | grep "../lib64" || sed -i 's:../lib:../lib64:g' ${S}/cmake/rosidl_cmake_export_typesupport_libraries-extras.cmake.in
    fi
}

