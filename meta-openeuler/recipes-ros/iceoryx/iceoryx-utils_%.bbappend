# make ros libs compatible with lib64
do_configure:prepend:class-target() {
    if [[ "${libdir}" =~ "lib64" ]]; then
        cat ${S}/cmake/IceoryxPackageHelper.cmake | grep "DESTINATION_LIBDIR lib64" || sed -i 's:DESTINATION_LIBDIR lib:DESTINATION_LIBDIR lib64:g' ${S}/cmake/IceoryxPackageHelper.cmake
        cat ${S}/cmake/IceoryxPackageHelper.cmake | grep "DESTINATION_CONFIGDIR lib64" || sed -i 's:DESTINATION_CONFIGDIR lib:DESTINATION_CONFIGDIR lib64:g' ${S}/cmake/IceoryxPackageHelper.cmake
    fi
}

