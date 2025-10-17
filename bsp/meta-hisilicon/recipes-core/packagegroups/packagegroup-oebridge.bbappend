INSTALL_PKG_LISTS:append = " \
${@bb.utils.contains('MACHINE', '3591rc', 'gcc', '', d)} \
"