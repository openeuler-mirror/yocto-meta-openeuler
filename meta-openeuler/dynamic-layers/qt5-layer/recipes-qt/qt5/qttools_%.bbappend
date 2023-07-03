require qt5-src.inc

SRC_URI:prepend = "file://qttools-opensource-src-5.13.2-runqttools-with-qt5-suffix.patch \
           file://qttools-opensource-src-5.7-add-libatomic.patch \
           file://0001-Link-against-libclang-cpp.so-instead-of-the-clang-co.patch \
           file://0001-modify-lupdate-qt5-run-error.patch \
           "
