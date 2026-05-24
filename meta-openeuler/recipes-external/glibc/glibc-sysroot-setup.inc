# stash_locale_cleanup removes the empty /usr/lib after stashing the locale
# files to avoid remnant clutter, but we need it in the sysroot
stash_locale_sysroot_cleanup:append() {
	# If the usr/lib directory doesn't exist, the toolchain fails to even
	# try to find crti.o in a completely different directory (usr/lib64)
	install -d ${SYSROOT_DESTDIR}${nonarch_libdir}
}

# OpenEuler uses usrmerge layout: all libraries are under usr/lib64.
# The dynamic linker and libc are referenced as /lib64/... by ELF binaries,
# so configure test programs fail to link if /lib64 doesn't exist in the
# sysroot. Create the compat symlink so every dependent recipe can link.
glibc_external_sysroot_lib64_compat() {
	if [ ! -e "${SYSROOT_DESTDIR}/lib64" ]; then
		ln -sf usr/lib64 "${SYSROOT_DESTDIR}/lib64"
	fi
}
SYSROOT_PREPROCESS_FUNCS += "glibc_external_sysroot_lib64_compat"
