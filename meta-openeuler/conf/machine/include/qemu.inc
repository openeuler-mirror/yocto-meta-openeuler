# common image fs type for qemu targets
IMAGE_FSTYPES = "cpio.gz"
IMAGE_FSTYPES_DEBUGFS = "cpio.gz"

MACHINEOVERRIDES =. "qemuall:"

# support runqemu function
IMAGE_CLASSES += "qemuboot"
EXTRA_IMAGEDEPENDS += "qemu-helper-native:do_addto_recipe_sysroot"
