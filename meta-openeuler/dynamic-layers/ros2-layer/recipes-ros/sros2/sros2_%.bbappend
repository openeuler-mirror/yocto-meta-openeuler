# python3-cryptography -> python3-cffi-> python3-pycparser-> cpp/cpp-symlinks-> gcc
# we current do not want gcc be embedded
ROS_EXEC_DEPENDS:remove = "python3-cryptography"
