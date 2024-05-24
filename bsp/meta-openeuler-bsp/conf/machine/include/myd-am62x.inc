require conf/machine/include/k3.inc
SOC_FAMILY:append = ":am62xx"

MACHINE_FEATURES += "screen gpu"

require conf/machine/include/mesa-pvr.inc
PREFERRED_PROVIDER_virtual/gpudriver ?= "ti-img-rogue-driver"

# Default tiboot3.bin on AM62x is for HS-FS
IMAGE_BOOT_FILES += "tiboot3-am62x-hs-fs-evm.bin"

# Since default tiboot3.bin on AM62x is for HS-FS, add a version for GP
IMAGE_BOOT_FILES += "tiboot3-am62x-gp-evm.bin"

# Since default tiboot3.bin on AM62x is for HS-FS, add a version for HS-SE
IMAGE_BOOT_FILES += "tiboot3-am62x-hs-evm.bin"

# Bitmap image tarball for early splashscreen
IMAGE_BOOT_FILES += "ti_logo_414x97_32bpp.bmp.gz"

TFA_BOARD = "lite"
TFA_K3_SYSTEM_SUSPEND = "1"

OPTEEMACHINE = "k3-am62x"

# Normally AM62 boards use ttyS2, but our Jailhouse inmate may use ttyS3, so try both
SERIAL_CONSOLES = "115200;ttyS2 115200;ttyS3"

IMAGE_FSTYPES += " ext4 "
