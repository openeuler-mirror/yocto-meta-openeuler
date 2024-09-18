inherit openeuler_source pkgconfig

EXTRA_OECMAKE += " -DBUILD_MATLAB_BINDINGS=OFF -DBUILD_PYTHON_BINDINGS=ON -DBUILD_TESTS=OFF"

SRC_URI:remove = "file://0001-Use-object-libraries-instead-of-empty-file-list-in-C.patch"
SRC_URI:append = " \
        file://flann/flann-1.9.1-fixpyflann.patch \
        file://flann/flann-libdir.patch \
        file://flann/flann-fix-lz4.patch \
        "

RDEPENDS:${PN} += " \
    boost \
    lz4 \
    python3-numpy \
"

DEPENDS += " \
    boost \
    gtest-native \
    lz4 \
    python3-native \
    python3-numpy \
    zlib-native \
"

FILES:${PN} += " /usr/share/flann "

# note:In the source code of libflann here, the reference to lz4 in the generated
# CMake file is an absolute path. This causes issues if the project build uses the
# rm_work class to reduce disk usage, as packages dependent on libflann will fail
# due to the non-existence of the lz4 dependency path. Therefore, until a solution
# for the absolute dependency path of lz4 is found, it needs to be added by default
# to RM_WORK_EXCLUDE to prevent the deletion of temporary build files.
# if you get interest, follow steps:
# 1: bitbake libflann
# 2: cd tmp/work/aarch64-openeuler-linux/libflann/1.9.2-r0/build/CMakeFiles/Export/<hash>
# 3: vim flann-targets-relwithdebinfo.cmake
# see flann:flann_cpp_s and flann:flann_s
RM_WORK_EXCLUDE  += "libflann"
