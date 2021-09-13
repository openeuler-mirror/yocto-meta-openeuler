# Copyright (C) Huawei Technologies Co., Ltd. 2020. All rights reserved.
# Description: Config for common machine
# Author: Huawei OS Kernel Lab
# Create: Sat Aug 29 01:15:17 2020

MACHINEOVERRIDES =. "hongmengmachine:"

AVAILTUNES += 'rruarm'
TUNE_CCARGS .= "${@bb.utils.contains('TUNE_FEATURES', 'rruarm', ' -mno-unaligned-access -mfpu=vfpv3-d16 -mfloat-abi=soft -freg-struct-return', '', d)}"
