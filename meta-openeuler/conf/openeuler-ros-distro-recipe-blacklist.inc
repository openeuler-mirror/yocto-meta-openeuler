# remove from blacklist for runtime decouple
SKIP_RECIPE[navigation2] = ""
SKIP_RECIPE[nav2-bringup] = ""
SKIP_RECIPE[slam-toolbox] = ""

# add to blacklist for runtime decouple
SKIP_RECIPE[git] = "Not building with openEuler Embedded ros runtime."
SKIP_RECIPE[gcc] = "Not building with openEuler Embedded ros runtime."

# current oe's tbb version is too new for ros
PREFERRED_VERSION_tbb = "2020.3"
