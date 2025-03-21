
PV = "3.24.41"

# openeuler patch
SRC_URI:prepend = "file://gtk+-${PV}.tar.xz \
           file://0001-Let-the-notification-icon-use-the-size-specified-by-.patch \
           "
# delete-taboo-words.patch: git patch error
#PATCHTOOL = "git"

# keep as upstream
PACKAGECONFIG[cups] = ",,cups,cups"
PACKAGECONFIG[cloudproviders] = "-Dcloudproviders=true,-Dcloudproviders=false,libcloudproviders"
PACKAGECONFIG[tracker3] = "-Dtracker3=true,-Dtracker3=false,tracker,tracker-miners"
