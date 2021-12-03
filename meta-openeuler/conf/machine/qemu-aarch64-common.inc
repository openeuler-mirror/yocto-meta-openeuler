# Description: Config for arm64 machine

MACHINEOVERRIDES =. "march64:"
require conf/machine/qemu-common.inc

# Different from arm32, here we use armv8a.inc instead
# of conf/machine/include/tune-cortexa53.inc because
# we are not sure our CPU is cortex a53.
require conf/machine/include/arm/arch-armv8a.inc

# but we are sure in compat32 we should use -mcpu=cortexa9.
# This is may not correct, but to make sure compat32 and arm32
# give same binary.
# Should not use conf/machine/include/tune-cortexa9.inc directly.
# In case when using compat32, we alert cflags with same way in tune-cortexa9.inc

TUNE_CCARGS .= "${@bb.utils.contains('TUNE_FEATURES', 'cortexa9', ' -mtune=cortex-a9', '', d)}"
MACHINEOVERRIDES =. "${@bb.utils.contains('TUNE_FEATURES', 'cortexa9', 'armv7a:', '' ,d)}"

MACHINEOVERRIDES_remove_virtclass-multilib-lib32 =. "march64:"
MACHINEOVERRIDES_append_virtclass-multilib-lib32 =. "march32:"
TUNE_FEATURES_append_virtclass-multilib-lib32 += " cortexa9"
TUNE_FEATURES_remove_virtclass-multilib-lib32 += " vfp"
