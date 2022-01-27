require dhcp.inc

COMPONENT = "isc dhcp"

LDFLAGS_append = " -pthread"

PACKAGECONFIG ?= ""
PACKAGECONFIG[bind-httpstats] = "--with-libxml2,--without-libxml2,libxml2"
