# To boot an image with guest os, we use the initramfs image as the Monitor VM.
# So, we need to configure GRUB_ROOT and INITRD
INITRD = "1"
GRUB_ROOT = "root=/dev/ram0 rootfstype=ext4 rootwait"

# And, we use a tiny DTB when enable BUILD_GUEST_OS, the sd card
# is not assigned to the MVM. So, we should not use init_resize.sh
APPEND:remove = "init=/usr/lib/init_resize.sh"

# Only 750M RAM is allowed for MVM, the rest can be given to GVM.
# This is related to jailhouse's cell. Of course we can configure a
# specific memory range for GVM via dtoverlay, but it may not be necessary.
APPEND:prepend = "mem=750M "
