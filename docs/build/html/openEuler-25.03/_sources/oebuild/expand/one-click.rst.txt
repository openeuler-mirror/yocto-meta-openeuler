.. _oebuild_expand_one_click:

如何一键式构建
###############

oebuild支持在oebuild工作目录下直接指定配置文件实现一键式构建功能，该功能是为了在特殊定制配置文件下可以直接进行构建，而无需进行其他流程步骤。使用方式如下：

.. code-block:: console

    oebuild /path/compile.yaml

配置文件格式与compile.yaml格式一样，但会添加bitbake_cmds字段，该字段是一个列表，表示自动执行的bitbake指令，以下是一个配置文件范例：

.. code-block:: console

    build_in: docker
    machine: raspberrypi4-64
    toolchain_type: EXTERNAL_TOOLCHAIN:aarch64
    no_layer: false
    repos:
     - yocto-poky
     - yocto-meta-openembedded
     - yocto-meta-raspberrypi
    local_conf: |+
    DISTRO_FEATURES:append = " clang ld-is-lld"
    DISTRO_FEATURES_NATIVE:append = " clang "
    EXTERNAL_TOOLCHAIN_CLANG_BIN = "${EXTERNAL_TOOLCHAIN_LLVM}/bin"

    layers:
     - yocto-meta-raspberrypi
     - yocto-meta-openeuler/meta-clang
    docker_param:
     image: swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/openeuler-container:latest
     parameters: -itd --network host
     volumns:
      - /dev/net/tun:/dev/net/tun
     command: bash

    bitbake_cmds:
     - bitbake zlib

以上配置文件在回车命令执行后会自动创建编译目录，并执行zlib的编译动作
