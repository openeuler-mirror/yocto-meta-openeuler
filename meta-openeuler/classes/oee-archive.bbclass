# this class is used to handle the situation where source code is staged in oee_archive repo
# (https://gitee.com/openeuler/oee_archive) or other archive repo
# oee_archive must be a git repo.

# the default repo name is oee_archive, which is used for do_openeuler_fetch
OPENEULER_LOCAL_NAME = "oee_archive"
OEE_ARCHIVE_SUB_DIR ?= "${BPN}"
# for real file path to search is ${OPENEULER_LOCAL_NAME}/${OEE_ARCHIVE_SUB_DIR},
# not OPENEULER_LOCAL_NAME.
OPENEULER_DL_DIR = "${OPENEULER_SP_DIR}/${OPENEULER_LOCAL_NAME}/${OEE_ARCHIVE_SUB_DIR}"
