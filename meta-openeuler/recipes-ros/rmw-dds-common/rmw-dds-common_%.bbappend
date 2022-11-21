# make ros libs compatible with lib64
# some lib can't change to lib64 by Cmake due to unknown reason, it is a workaround here
do_install:append:class-target() {
    if [[ "${libdir}" =~ "lib64" ]]; then
        mv ${D}/usr/lib/* ${D}/${libdir}
        ls ${D}/usr/lib/* || rm -rf ${D}/usr/lib/
        cmakefilename="${D}/usr/share/rmw_dds_common/cmake/rmw_dds_common__rosidl_generator_cExport-noconfig.cmake"
        cat ${cmakefilename} | grep "lib64/librmw_" || sed -i 's:lib/librmw_:lib64/librmw_:g' ${cmakefilename}
    fi
}

