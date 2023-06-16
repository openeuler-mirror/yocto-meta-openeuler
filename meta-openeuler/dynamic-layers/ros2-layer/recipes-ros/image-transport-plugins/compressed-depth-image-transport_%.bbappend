# ingore format check like: 
# rcutils_log(&__rcutils_logging_location, severity, name, __VA_ARGS__);
#                                                                ^

CFLAGS += " -Wno-error=format-security "
CXXFLAGS += " -Wno-error=format-security "
