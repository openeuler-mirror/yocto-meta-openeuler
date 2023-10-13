.. _command_index_init:

初始化目录命令-init
############################

初始化命令是使用oebuild的一切相关命令的前提，初始化命令如下：

.. code-block:: console

    oebuild init [-u yocto_remote_url] [-b branch] [directory]

初始化命令主要是对oebuild的工作目录进行初始化，主要执行如下操作：

- 在当下路径创建工作目录

- 在工作目录中创建配置目录.oebuild

- 向配置目录中拷贝并修改公共配置文件config.yaml与compile.yaml.sample

- 在工作目录下创建源码目录src

命令参数介绍：

-u：表示主构建仓远程地址，该参数默认值为"https://gitee.com/openeuler/yocto-meta-openeuler.git"

-b：表示主构建仓的分支选项，该参数默认值为"master"

directory：表示要初始化的工作目录名，如果当下已经存在要初始化的目录名，则会报错误"mkdir <directory> failed"
