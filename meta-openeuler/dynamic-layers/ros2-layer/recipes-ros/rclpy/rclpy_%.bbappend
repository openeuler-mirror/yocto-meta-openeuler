# fix name error,:
# _rclpy_pybind11.cpython-39-x86_64-linux-gnu.so: ELF 64-bit LSB shared object, ARM aarch64, version 1 (SYSV), dynamically linked
# -> _rclpy_pybind11.cpython-39-aarch64-linux-gnu.so
do_install:append() {
    if [ ! -e ${D}/${PYTHON_SITEPACKAGES_DIR}/${ROS_BPN}/_rclpy_pybind11.${PYTHON_SOABI}.so ]; then
        mv ${D}/${PYTHON_SITEPACKAGES_DIR}/${ROS_BPN}/_rclpy_pybind11.cpython*.so ${D}/${PYTHON_SITEPACKAGES_DIR}/${ROS_BPN}/_rclpy_pybind11.${PYTHON_SOABI}.so
    fi
}

INSANE_SKIP:${PN} += "already-stripped"
SRC_URI[sha256sum] = "6f685bf6eba43ac21f6dcfad35142f76d4aab519c791572a82433e4fe0f35f16"
