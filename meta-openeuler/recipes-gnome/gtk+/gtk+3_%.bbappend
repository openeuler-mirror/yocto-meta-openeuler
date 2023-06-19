OPENEULER_REPO_NAME = "gtk3"

PV = "3.24.36"

# openeuler patch
SRC_URI:prepend = "file://0001-Let-the-notification-icon-use-the-size-specified-by-.patch \
           "

# Missing or unbuildable dependency chain was: ['gtk+3', 'adwaita-icon-theme-symbolic', 'librsvg-native', 'cargo-native', 'cargo-bin-native-x86_64']
GTKBASE_RRECOMMENDS:remove =  "adwaita-icon-theme-symbolic"

# not support glibc-locale now
GTKGLIBC_RRECOMMENDS:remove = "glibc-gconv-iso8859-1"
