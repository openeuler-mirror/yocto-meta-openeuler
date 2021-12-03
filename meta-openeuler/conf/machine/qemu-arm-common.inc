# Description: Conf for arm

MACHINEOVERRIDES =. "march32:"
require conf/machine/qemu-common.inc
require conf/machine/include/tune-cortexa9.inc

TUNE_FEATURES_append += " cortexa9"
TUNE_FEATURES_remove += " vfp"

TUNE_CCARGS .= " -mno-unaligned-access"
