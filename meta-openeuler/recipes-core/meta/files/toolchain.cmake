# CMake system name must be something like "Linux".
# This is important for cross-compiling.

set( CMAKE_SYSTEM_NAME Linux )
set( CMAKE_SYSTEM_PROCESSOR $ENV{OECORE_TARGET_ARCH} )
set( CMAKE_C_COMPILER $ENV{CROSS_COMPILE}gcc )
set( CMAKE_CXX_COMPILER $ENV{CROSS_COMPILE}g++ )
set( CMAKE_C_COMPILER_TARGET $ENV{CROSS_COMPILE}gcc )
set( CMAKE_CXX_COMPILER_TARGET $ENV{CROSS_COMPILE}g++ )
set( CMAKE_C_COMPILER_LAUNCHER  )
set( CMAKE_CXX_COMPILER_LAUNCHER  )
set( CMAKE_ASM_COMPILER $ENV{CROSS_COMPILE}gcc )
find_program( CMAKE_AR $ENV{AR} DOC "Archiver" REQUIRED )

# Currently, OPENEULER_NATIVESDK_DIR uses a fixed address.
# After optimizing the nativesdk, a generative or parameterized optimization can be performed here.
set( OPENEULER_NATIVESDK_DIR "/opt/buildtools/nativesdk/sysroots/x86_64-pokysdk-linux/usr/bin" )
if ($ENV{OECORE_NATIVE_SYSROOT} MATCHES "/sysroots/([a-zA-Z0-9_-]+)-.+-.+")
  set( OPENEULER_NATIVE_SYSROOT_BIN "$ENV{OECORE_NATIVE_SYSROOT}/usr/bin" )
endif()
set( CMAKE_SYSROOT "$ENV{OECORE_TARGET_SYSROOT}" )
set( TARGET_SYSROOT_DIR  "$ENV{OECORE_TARGET_SYSROOT}" )

set( NATIVEPYTHONPATH "${NATIVE_SYSROOT_DIR}/usr/lib/python3.9/site-packages" )
set( TARGETPYTHONPATH "${TARGET_SYSROOT_DIR}/usr/lib/python3.9/site-packages" )
set( ENV{PYTHONPATH} "${TARGETPYTHONPATH}:${NATIVEPYTHONPATH}" )

set( ENV{AMENT_PREFIX_PATH} "$ENV{OECORE_TARGET_SYSROOT}/usr" )
set( ENV{LD_LIBRARY_PATH} "$ENV{OECORE_TARGET_SYSROOT}/usr/lib:$ENV{OECORE_TARGET_SYSROOT}/usr/lib64:$ENV{LD_LIBRARY_PATH}" )

set ( ENV{PKG_CONFIG_SYSROOT_DIR} "$ENV{OECORE_TARGET_SYSROOT}" )
set ( ENV{PKG_CONFIG_PATH} "${PKG_CONFIG_SYSROOT_DIR}/usr/lib/pkgconfig:${PKG_CONFIG_SYSROOT_DIR}/usr/share/pkgconfig:${PKG_CONFIG_SYSROOT_DIR}/usr/lib64/pkgconfig:${PKG_CONFIG_SYSROOT_DIR}/lib64/pkgconfig" )

execute_process(COMMAND bash -c "echo \${CC#* }" OUTPUT_VARIABLE OPENEULER_CC_FLAGS)
execute_process(COMMAND bash -c "echo \${CXX#* }" OUTPUT_VARIABLE OPENEULER_CXX_FLAGS)
execute_process(COMMAND bash -c "echo \${LD#* }" OUTPUT_VARIABLE OPENEULER_LD_FLAGS)
string(STRIP "${OPENEULER_CC_FLAGS}" OPENEULER_CC_FLAGS)
string(STRIP "${OPENEULER_CXX_FLAGS}" OPENEULER_CXX_FLAGS)
string(STRIP "${OPENEULER_LD_FLAGS}" OPENEULER_LD_FLAGS)

set( CMAKE_C_FLAGS " ${OPENEULER_CC_FLAGS}  --sysroot=${TARGET_SYSROOT_DIR} " CACHE STRING "CFLAGS" )
set( CMAKE_CXX_FLAGS " ${OPENEULER_CXX_FLAGS}  --sysroot=${TARGET_SYSROOT_DIR}" CACHE STRING "CXXFLAGS" )
set( CMAKE_ASM_FLAGS " ${OPENEULER_CC_FLAGS} --sysroot=${TARGET_SYSROOT_DIR} " CACHE STRING "ASM FLAGS" )
set( CMAKE_C_FLAGS_RELEASE "-DNDEBUG" CACHE STRING "Additional CFLAGS for release" )
set( CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG" CACHE STRING "Additional CXXFLAGS for release" )
set( CMAKE_ASM_FLAGS_RELEASE "-DNDEBUG" CACHE STRING "Additional ASM FLAGS for release" )
set( CMAKE_C_LINK_FLAGS " ${OPENEULER_LD_FLAGS} $ENV{LDFLAGS} --sysroot=${TARGET_SYSROOT_DIR}" CACHE STRING "LDFLAGS" )
set( CMAKE_CXX_LINK_FLAGS " ${OPENEULER_LD_FLAGS} $ENV{LDFLAGS} --sysroot=${TARGET_SYSROOT_DIR}" CACHE STRING "LDFLAGS" )

# only search in the paths provided so cmake doesnt pick
# up libraries and tools from the native build machine
set( CMAKE_FIND_ROOT_PATH ${TARGET_SYSROOT_DIR} ${OPENEULER_NATIVESDK_DIR} ${OPENEULER_NATIVE_SYSROOT_BIN} ${CMAKE_INSTALL_PREFIX} )
set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
set( CMAKE_PROGRAM_PATH "/" )

# We need to set the rpath to the correct directory as cmake does not provide any
# directory as rpath by default
set( CMAKE_INSTALL_RPATH  )

# Use RPATHs relative to build directory for reproducibility
set( CMAKE_BUILD_RPATH_USE_ORIGIN ON )

# Use our cmake modules
list(APPEND CMAKE_MODULE_PATH "${TARGET_SYSROOT_DIR}/usr/share/cmake/Modules/")

# add for non /usr/lib libdir, e.g. /usr/lib64
set( CMAKE_LIBRARY_PATH ${CMAKE_INSTALL_PREFIX}/lib)
set( CMAKE_PREFIX_PATH ${CMAKE_INSTALL_PREFIX}/lib)
set( CMAKE_SYSTEM_LIBRARY_PATH ${CMAKE_INSTALL_PREFIX}/lib)

