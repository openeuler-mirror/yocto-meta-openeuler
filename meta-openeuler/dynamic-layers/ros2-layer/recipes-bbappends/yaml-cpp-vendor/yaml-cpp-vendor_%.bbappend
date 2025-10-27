# remove patch because the patch will create CMakeLists.txt, however,
# the source code already has CMakeLists.txt, so we need to remove the patch
SRC_URI:remove = "file://0001-Use-platform-yaml-cpp.patch"
