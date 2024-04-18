require conf/machine/include/${SOC_FAMILY}.inc
require rzg2-common.inc

# Firmware-pack 
EXTRA_IMAGEDEPENDS += " firmware-pack"

MACHINEOVERRIDES =. "rzg2l:"

BBMASK:append = " recipes-rzg2h|recipes-rzv2l"
