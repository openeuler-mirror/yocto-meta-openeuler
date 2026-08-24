# tftp-hpa calls bsd_signal() in tftp.c/main.c; glibc only declares it under
# __USE_XOPEN_EXTENDED && !__USE_XOPEN2K8 (i.e. _XOPEN_SOURCE < 700), but the
# default _DEFAULT_SOURCE (auto-defined with the non-strict gnu11 standard)
# sets _XOPEN_SOURCE=700 -> __USE_XOPEN2K8, hiding bsd_signal. clang treats
# the implicit-function-declaration as a hard C99+ error. bsd_signal is just
# the BSD-flavoured signal(); map it to signal() which is always declared.
CFLAGS:append:toolchain-clang = " -Dbsd_signal=signal"
