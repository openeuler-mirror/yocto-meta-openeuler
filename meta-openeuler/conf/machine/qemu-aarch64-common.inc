# Copyright (C) Huawei Technologies Co., Ltd. 2020. All rights reserved.
# Description: Config for arm64 machine
# Author: Huawei OS Kernel Lab
# Create: Sat Aug 29 01:15:17 2020

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

COMPAT32_MACHINEOVERRIDES_DEL =. "march64:"
COMPAT32_MACHINEOVERRIDES_ADD =. "march32:"
COMPAT32_TUNE_FEATURES_APPEND += " cortexa9"
COMPAT32_TUNE_FEATURES_REMOVE += " vfp"

HMKERNEL_ARCH_march64 = 'aarch64'
HMKERNEL_ARCH_compat32 = 'arm'
