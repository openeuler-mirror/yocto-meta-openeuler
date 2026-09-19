.. _qemu_debug:

QEMU调试
########

QEMU的一大优势是可以使用 gdb 来对内核进行调试，这对于嵌入式开发者来说能极大地提高开发效率。
在原有的开发环境中，如果想调试内核，只能在出问题的代码附近加上printk打印，重编内核，将镜像烧到开发板上查看打印信息。如果出问题的阶段非常早，无法调用 printk，还需要手动实现往串口物理地址打印的代码。
而基于QEMU，可以直接使用 gdb 在内核需要调试的位置下断点，查看对应的寄存器和变量的值。本文档主要介绍如何通过 QEMU 进行 openEuler Embedded 内核的调试。

1. 调试准备
===========

   除了启动 QEMU 所必须的内核、根文件系统之外，我们还需要一个携带调试信息的 ``vmlinux`` 文件。vmlinux 在 oebuild 镜像构建目录下的 ``output`` 文件夹中可以找到，
   也可以在 `dailybuild <http://121.36.84.172/dailybuild/openEuler-Mainline/>`_  中下载。

   注意，请确保 vmlinux 和 zImage 是由同一份内核源码和同一份内核 config 生成，否则调试信息可能是错误的。

2. 调试步骤
===========

   以aarch64为例，介绍如何使用qemu进行内核调试。

   启动qemu时，需要添加 ``-S -s`` 参数，可以让qemu启动后不立即加载内核，而是在 ``localhost:1234`` 上启动gdbserver，等待gdb连接：

   .. code-block:: console

      $ qemu-system-aarch64 -M virt-4.0 -m 1G -cpu cortex-a57 -nographic \
          -kernel zImage \
          -initrd openeuler-image-qemu-aarch64-*.rootfs.cpio.gz \
          -S -s

   可以发现此时命令行不再继续往下执行，我们另外打开一个窗口，启动gdb并连接qemu：
   (如果使用的是arm64内核，需要gdb-multiarch进行调试)

   .. code-block:: console

      $ gdb
      (gdb) file vmlinux
      (gdb) target remote :1234
      (gdb) b start_kernel
      (gdb) c

   上面的 ``target remote :1234`` 用于连接qemu启动的gdb server； ``file vmlinux`` 用于加载符号信息。
   在执行完 ``c`` 之后，内核会开始运行，遇到我们在start_kernel下的断点后会再次停止，此时可以通过 ``p / bt`` 等方式查看变量或调用栈。

   .. note::

      | openEuler Embedded 的ARM64内核添加了自解压特性，因此内核构建会生成两个vmlinux。
      | 一个在内核构建根目录下，也就是上文使用的vmlinux，这份vmlinux是内核在自解压之后的运行代码镜像。
      | 另一个在内核构建目录 ``arch/arm64/boot/compressed`` 里面，是内核在自解压之前运行的代码，调试自解压部分时，需要让gdb读取这份vmlinux：

      .. code-block:: console

         (gdb) add-symbol-file vmlinux 0x40080000

      0x40080000对应的地址实际上就是qemu加载zImage的位置，可以在qemu的控制台通过 ``info roms`` 查看。

附录：调试内核时常用的gdb命令
=============================

   - **p**: 打印通用寄存器或者变量。 ``p $x1`` 或者 ``p command_line``
   - **x/32wx addr**: 以16进制，按word(32位)为单位，打印从addr开始的32个值
   - **disas [addr]**: 反汇编，可以结合qemu.log和objdump后的vmlinux一起查看
   - **n, s / ni, si**: 单步执行，ni,si 针对汇编
   - **info registers**: 打印寄存器
   - **bt**: 查看调用栈
   - **b [addr] [if condition]**: 断点，某些场景下可能需要条件断点来过滤部分（如想查看某个中断是否上报可以在中断入口处增加调试断点，减少非预期的停止）
