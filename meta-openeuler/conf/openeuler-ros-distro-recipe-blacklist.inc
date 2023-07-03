# remove from blacklist for runtime decouple
SKIP_RECIPE[navigation2] = ""
SKIP_RECIPE[nav2-bringup] = ""
SKIP_RECIPE[slam-toolbox] = ""

# current oe's tbb version is too new for ros-foxy
PREFERRED_VERSION_tbb = "2020.3"
