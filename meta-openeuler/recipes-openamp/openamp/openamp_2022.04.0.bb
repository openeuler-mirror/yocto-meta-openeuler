require openamp.inc

OPENEULER_REPO_NAME = "OpenAMP"

# In openeamp demo, we use screen to open pty shell
RDEPENDS_${PN} += "screen"
