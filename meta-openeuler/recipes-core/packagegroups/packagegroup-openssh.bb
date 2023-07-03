SUMMARY = "OpenSSH SSH client/server"
PR = "r1"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
openssh-ssh \
openssh-sshd \
openssh-scp \
openssh-keygen \
openssh-misc \
openssh-sftp \
openssh-sftp-server \
"
