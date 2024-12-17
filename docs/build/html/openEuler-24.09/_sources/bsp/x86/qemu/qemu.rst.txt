QEMU-X86-64
###########

基本介绍
========

目前openEuler Embedded支持使用QEMU启动x86镜像，方便开发人员体验openEuler Embedded的功能，也可以快速进行基本的嵌入式Linux开发。

____

构建说明
========

.. seealso::

   参考 :ref:`openEuler Embedded x86-64镜像构建 <board_x86_build>`.

____

运行说明
========

构建完成后，在 ``<build_x86>/output`` 目录下可以看到镜像，如：

   .. code-block:: shell

      $ tree
      .
      └── 20230315093436
          ├── bzImage -> bzImage-5.10.0
          ├── bzImage-5.10.0
          ├── openeuler-image-generic-x86-64-20230315093436.iso
          ├── openeuler-image-generic-x86-64-20230315093436.rootfs.cpio.gz
          └── vmlinux-5.10.0

可以使用以下命令启动openEuler-Embedded：

   .. code-block:: shell

      sudo qemu-system-x86_64 -m 1G -nographic -append 'console=ttyS0' –kernel bzImage –initrd *.rootfs.cpio.gz

____

安装说明
========

QEMU支持X86的iso镜像安装，步骤如下：

1. 创建一个用于挂载的磁盘：

   .. code-block:: shell

      qemu-img create disk.img 8G

2. 下载 `OVMF.fd <https://cdn.download.clearlinux.org/image/OVMF.fd>`_;

3. 使用以下命令启动QEMU：

   .. code-block:: shell

      sudo qemu-system-x86_64 -m 1G -nographic -cdrom openeuler-image-*.iso -bios OVMF.fd -hda disk.img

   进入gurb界面后，选择 ``boot`` 可以进入live os，一般用于debug；选择 ``install`` 进入系统安装流程。

4. 选择 ``install`` 后，进行系统安装，依次输入cdrom和安装盘：

   .. image:: qemu-install.png

   之后稍作等待，完成系统安装后，会提示： ``Installation successful. Remove your installation media and press ENTER to reboot.`` 此时可以直接按 ``<CTRL-a> + x`` 关闭QEMU。

5. 之后都可以通过disk.img启动openEuler-Embedded：

   .. code-block:: shell

      sudo qemu-system-x86_64 -m 1G -nographic -bios OVMF.fd -hda disk.img
