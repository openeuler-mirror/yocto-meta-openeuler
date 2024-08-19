# prepare SDK
PYTHONBIN=`which python3`
PYTHONVERSION=`python3 --version | awk -F "." '{print $2}'`

# prepare context for kernel module development
cd "${SDKTARGETSYSROOT}/usr/src/kernel"
make modules_prepare PKG_CONFIG_SYSROOT_DIR= PKG_CONFIG_PATH=
cd -

# ROS2 SDK related handling
if [ -f "${OECORE_NATIVE_SYSROOT}/usr/bin/colcon" ];then

    echo "Preparing ROS2 SDK..."
    # cmake toolchain file for ros2 SDK
    export CMAKE_TOOLCHAIN_FILE="$OECORE_NATIVE_SYSROOT/environment-setup.d/toolchain.cmake"
    # add target python3 site-packages path
    export PYTHONPATH="${PYTHONPATH}:${OECORE_TARGET_SYSROOT}/usr/lib/python3.${PYTHONVERSION}/site-packages"
    # COLCON_WORKSPACE_PATH is used to set the CMAKE_FIND_ROOT_PATH in toolchian.cmake
    # so it will be easier to find cmake modules, or cmake will complain about Findxxxx.cmake error
    alias colcon='export COLCON_WORKSPACE_PATH=`pwd`  && colcon'


    if [ ! -f "$OECORE_NATIVE_SYSROOT/environment-setup.d/ros2_fix.done" ];then
        # add cross compile support for colcon

        # avoid pythonpath err in colcon
        sed -i "s%python_path.exists():%python_path.exists() and not (\"\%s\" \% python_path).startswith(\"${OECORE_NATIVE_SYSROOT}/usr/lib\"):%" ${OECORE_NATIVE_SYSROOT}/usr/lib/python3.*/site-packages/colcon_core/environment/pythonpath.py

        # add find_path cross compile support for numpy path
        sed -i '/_NumPy_PATH/{n; s%NO_DEFAULT_PATH)%NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH)%}' ${OECORE_NATIVE_SYSROOT}/usr/share/cmake*/Modules/FindPython/Support.cmake

        # fix the wrong path in.cmake files.
        # from "/home/openeuelr*recipe-sysroot" to ${TARGET_SYSROOT_DIR}
        # from build path to the correct path in the SDK
        cmakefiles=`find ${SDKTARGETSYSROOT} -name "*\.cmake"`
        for cmakefile in $cmakefiles
        do
            res=`cat $cmakefile | grep recipe-sysroot`
            if [ $? -eq 0 ];then
                echo "Auto Check: $cmakefile"
                sed -i 's#recipe-sysroot#@@@@#g' $cmakefile
                sed -i 's#/home/[^@]*@@@@#\${TARGET_SYSROOT_DIR}#g' $cmakefile
            fi
        done
        touch "$OECORE_NATIVE_SYSROOT/environment-setup.d/ros2_fix.done"
    else
        echo "ROS2 SDK related SDK file fixes are already done."
    fi

    echo "ROS2 SDK prepared."
fi
