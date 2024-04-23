export KERNEL_SRC="${SDKTARGETSYSROOT}/usr/src/kernel"
OPENEULER_NATIVESDK_SYSROOT=/opt/buildtools/nativesdk/sysroots/x86_64-openeulersdk-linux
# prepare SDK
PYTHONBIN=`which python3`
PYTHONVERSION=`python3 --version | awk -F "." '{print $2}'`
PYTHONPKGPATH="${PYTHONBIN%/*}/../lib/python3.${PYTHONVERSION}/site-packages/"
# auto add COLCON_WORK_PATH for toolchain.cmake, make colcon find pkg install from this path when build
alias colcon='export COLCON_WORK_PATH=`pwd`  && colcon'
if [ ${PYTHONPKGPATH#${OPENEULER_NATIVESDK_SYSROOT}} != "$PYTHONPKGPATH" ]; then
    # prepare context for kernel module development when using nativesdk
    pushd "${SDKTARGETSYSROOT}/usr/src/kernel"
    make modules_prepare PKG_CONFIG_SYSROOT_DIR= PKG_CONFIG_PATH= KBUILD_HOSTCFLAGS+="-L${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                            -L${OPENEULER_NATIVESDK_SYSROOT}/lib \
                            -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                            -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/lib \
                            -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                            -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/lib"
    popd

    # ROS SDK configuration for openeuler docker using nativesdk
    if test -d $PYTHONPKGPATH; then
        if test -d ${SDKTARGETSYSROOT}/usr/share/rosidl_cmake; then
            # prepare ROS SDK, only works in the ROS environment with our nativesdk.
            pushd $PYTHONPKGPATH
            # Here, we have a symbolic link for the Python package that is used by the ROS package
            # in the lib directory of our sysroot environment, instead of lib64.
            find . -type l -delete
            for file in ${SDKTARGETSYSROOT}/usr/lib/python3.*/site-packages/*
            do
                ln -sfnT "$file" "$(basename "$file")"
                if [ ! $? == 0 ];then
                    dirowner=`ls -al $PYTHONPKGPATH | sed -n '2p' | awk '{print $3}'`
                    if [ ! "$dirowner" == "openeuler" ];then
                        echo "The directory permissions do not match the current user. Try:"
                        echo "sudo chown openeuler:openeuler $PYTHONPKGPATH"
                    fi
                fi
            done
            popd

            # Install host python tools
            python3 -m pip install -r $OECORE_NATIVE_SYSROOT/environment-setup.d/requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
            # Fix nativesdk pytest=0.0.0 BUG, delete residual old version pytest from nativesdk
            rm -rf ${OPENEULER_NATIVESDK_SYSROOT}/usr/lib/python3.*/site-packages/pytest-0.0*
            export CMAKE_TOOLCHAIN_FILE="$OECORE_NATIVE_SYSROOT/environment-setup.d/toolchain.cmake"
	    # avoid pythonpath err in colcon
            sed -i 's%python_path.exists():%python_path.exists() and not (\"\%s\" \% python_path).startswith("/opt/buildtools/nativesdk/sysroots/x86_64-openeulersdk-linux/usr/lib"):%' ${OPENEULER_NATIVESDK_SYSROOT}/usr/lib/python3.*/site-packages/colcon_core/environment/pythonpath.py
        fi 
        # add find_path cross compile support for numpy path 
        sudo sed -i '/_NumPy_PATH/{n; s%NO_DEFAULT_PATH)%NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH)%}' /usr/share/cmake*/Modules/FindPython/Support.cmake 
        # fix .cmake lib dir from "/home/openeuelr*recipe-sysroot" to ${TARGET_SYSROOT_DIR} 
        cmakefiles=`find ${SDKTARGETSYSROOT} -name "*\.cmake"` 
        for cmakefile in $cmakefiles 
        do 
            res=`cat $cmakefile | grep recipe-sysroot` 
            if [ $? == 0 ];then 
                echo "Auto Check: $cmakefile" 
                sed -i 's#recipe-sysroot#@@@@#g' $cmakefile 
                sed -i 's#/home/[^@]*@@@@#\${TARGET_SYSROOT_DIR}#g' $cmakefile 
            fi 
        done 
        # fix make not found (CMAKE_MAKE_PROGRAM is not set)
        ln -sfnT /usr/bin/make  ${OPENEULER_NATIVESDK_SYSROOT}/usr/bin/make
    fi
else
    # prepare context for kernel module development
    pushd "${SDKTARGETSYSROOT}/usr/src/kernel"
    make modules_prepare PKG_CONFIG_SYSROOT_DIR= PKG_CONFIG_PATH=
    popd
    echo "No environment configuration detected for ROS SDK."
    echo "If you need to use ROS SDK, please make sure to use ROS image and use 'oebuild bitbake' to enter the docker environment"
fi

