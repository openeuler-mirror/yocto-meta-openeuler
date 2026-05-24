OPENEULER_LOCAL_NAME = "vim"

require vim-openeuler.inc

# vim.tiny embeds build paths; suppress QA warning (expected for stripped C binaries)
INSANE_SKIP:vim-tiny += "buildpaths"
