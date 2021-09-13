# Copyright (C) Huawei Technologies Co., Ltd. 2020. All rights reserved.
# Description: Conf for arm
# Author: Huawei OS Kernel Lab
# Create: Thu Sep 10 15:06:26 2020

MACHINEOVERRIDES =. "march32:"
require conf/machine/qemu-common.inc
require conf/machine/include/tune-cortexa9.inc

TUNE_FEATURES_append += " cortexa9"
TUNE_FEATURES_remove += " vfp"

TUNE_CCARGS .= " -mno-unaligned-access"

HMKERNEL_ARCH_march32 = 'arm'
