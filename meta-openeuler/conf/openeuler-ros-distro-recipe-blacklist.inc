# remove from blacklist for runtime decouple
SKIP_RECIPE[navigation2] = ""
SKIP_RECIPE[nav2-bringup] = ""
SKIP_RECIPE[slam-toolbox] = ""
SKIP_RECIPE[libg2o] = ""

# temporarily using the full version of suitesparse 
# it can be cropped later
SKIP_RECIPE[suitesparse-cholmod] = "Please Use suitesparse instead."

# add to blacklist for runtime decouple
SKIP_RECIPE[git] = "Not building with openEuler Embedded ros runtime."
SKIP_RECIPE[gcc] = "Not building with openEuler Embedded ros runtime."
