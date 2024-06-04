.. _oebuild:

oebuild使用指导
###################################

`oebuild <https://gitee.com/openeuler/oebuild>`__ 是一个用于构建和配置 openEuler Embedded 的工具，
能够为用户简化 openEuler Embedded 的构建流程，自动化生成定制化的 openEuler Embedded 发行版。

oebuild 的主要功能包括：

* 自动化下载不同版本的构建依赖，包括 `yocto-meta-openeuler <https://gitee.com/openeuler/yocto-meta-openeuler>`_ ,
  `yocto-poky <https://gitee.com/openeuler/yocto-poky>`_ , `yocto-meta-openembedded <https://gitee.com/openeuler/yocto-meta-openembedded>`_ 等。
* 根据用户的构建选项（机器类型，功能特性等等），创建出定制化的镜像配置文件。
* 使用容器创建一个隔离的构建环境，降低主机污染风险，简化构建系统的配置和依赖管理。
* 启动 openEuler Embedded 镜像构建。

============================

.. toctree::
   :maxdepth: 1

   userguide/index.rst
   expand/index.rst
   faq/index.rst
   release/index.rst

