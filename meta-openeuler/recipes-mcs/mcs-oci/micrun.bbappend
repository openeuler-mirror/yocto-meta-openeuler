MICRUN_SRC = "${S}/micrun"
MICRUN_GOPROXY="https://goproxy.cn,https://goproxy.io,https://mirrors.aliyun.com/goproxy/,direct"
# NOTICE: if change GOBUILD_MODE to "offline", please implement do_fetch() manually
# offline mode is for "do_compile" only, currently we use do_setup_deps() to make do_compile offline already
# no need to brings dependencies into SRC_URI in do_fetch(), which is really dirty
GOBUILD_MODE = "online"
