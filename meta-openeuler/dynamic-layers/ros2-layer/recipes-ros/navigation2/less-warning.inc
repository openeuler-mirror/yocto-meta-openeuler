# ignore like:
# warning: redundant redeclaration of 'constexpr' static data member 'sensor_msgs::msg::PointField_<ContainerAllocator>::FLOAT64' [-Wdeprecated]
# constexpr uint8_t PointField_<ContainerAllocator>::FLOAT64;
CXXFLAGS += " -Wno-error=deprecated -Wno-error=maybe-uninitialized -Wno-error=deprecated-declarations -Wno-error=format-security"
