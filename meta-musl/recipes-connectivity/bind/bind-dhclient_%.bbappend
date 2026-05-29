# bind-dhclient's libisc uses _Unwind_GetIP (from libgcc_s) when backtrace
# support is enabled (the default).  The external ARM musl toolchain does not
# ship libgcc_s as a shared library, so the link fails with an undefined
# reference.  Disable the backtrace feature; it is only useful for debugging
# BIND itself and is not required for dhclient operation.
EXTRA_OECONF:append:arm = " --disable-backtrace"
