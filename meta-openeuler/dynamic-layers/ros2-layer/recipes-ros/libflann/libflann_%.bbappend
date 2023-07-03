inherit openeuler_source

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
