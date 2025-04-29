openEuler包管理器EPKG
#####################

总体介绍
========

epkg 是 openEuler 提出新型包管理工具，能够解决多版本兼容性问题，用户可以在一个操作系统上通过命令安装不同版本的软件包。同时支持环境管理实现环境的创建/切换/使能/回退等操作，实现用户在误操作或安装软件后出现问题时恢复环境。

openEuler Embedded 25.03 版本后已默认支持 epkg 包管理器，能够让嵌入式接入epkg软件生态，拥有轻量灵活的包管理能力。

____

构建指导
========

openEuler Embedded 25.03 版本已默认在 QEMU-ARM64、KP920 中提供 epkg 的支持。若需要在其它镜像中增加 epkg 功能，请通过 oebuild 指定 ``-f epkg`` 进行构建。

____

使用指导
========

.. seealso::

   详细使用方法请参考 `EPKG包管理器使用说明 <https://gitee.com/openeuler/epkg/blob/master/doc/epkg-usage.md#epkg%E5%8C%85%E7%AE%A1%E7%90%86%E5%99%A8%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E>`_ 。

以下为使用示例：

1. EPKG包管理器命令说明

   .. code-block:: console

      Usage:
          epkg install <package>
          epkg remove [-y] <package>
          epkg upgrade <package> （开发中...）

          epkg list <glob-pattern>

          epkg env list
          epkg env create <env_name> [--repo <repo_name>]
          epkg env remove <env_name>
          epkg env activate <env_name> [--pure]
          epkg env deactivate <env_name>
          epkg env register|unregister <env_name>
          epkg env history
          epkg env rollback <history_id>

2. 安装软件

  功能描述：在当前activate的环境中安装软件，若无环境激活，默认安装到main环境中：``epkg env activate <env_name>``

  命令：``epkg install <package>``

  示例：

  .. code-block:: console

     $ epkg env create t1
     EPKG_ACTIVE_ENV:
     Environment t1 not exist.
     Environment 't1' has been created.
     Environment 't1' activated.

     $ epkg install htop
     EPKG_ACTIVE_ENV: t1
     Warning: The following packages are already installed and will be skipped:
     - 6sgyzx3s7624r0x7rpe4w8642p2d181r__fuse__2.9.9__11.oe2403
     - 3gypc46xq6mqd37ya3mhztz2zfkjghw1__libsigsegv__2.14__1.oe2403
     ....
     Attention: Install success: v0wrq5sv9r5znsgtgxkbax24r7f6nq80__htop__3.3.0__1.oe2403

3. 卸载软件

  功能描述：在当前activate的环境中安装软件，若无环境激活，默认安装到main环境中：``epkg env activate <env_name>``

  命令：``epkg remove <package>``

  示例：

  .. code-block:: console

     $ epkg env activate t1
     Environment 't1' activated.
     
     $ epkg remove htop
     Packages to remove:
     - v0wrq5sv9r5znsgtgxkbax24r7f6nq80__htop__3.3.0__1.oe2403
     Do you want to continue with uninstallation? (y/n):
     y
     Attention: Remove success: v0wrq5sv9r5znsgtgxkbax24r7f6nq80__htop__3.3.0__1.oe2403
